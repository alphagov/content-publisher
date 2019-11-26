# frozen_string_literal: true

class ResyncService < ApplicationService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    if document.live_edition.present?
      republish_live_edition
      update_draft_edition unless document.live_edition == document.current_edition
    else
      update_draft_edition
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def republish_live_edition
    # Now we want to promote the content item and assets from
    # the draft stack to the live stack. We can't use the
    # PublishService here as it would promote `current_edition`
    # to `live_edition`. (We just want to resync the two with
    # Publishing API, not change their states). It also calls
    # `publish` rather than `republish`.
    # And we can't use PreviewService for presenting the doc
    # to publishing API as there is no way of hooking the
    # `update_type`/`bulk_publishing` into the payload.
    # (We could - and possibly should - modify the
    # PreviewService to allow us to pass this override)

    payload = PreviewService::Payload.new(document.live_edition).payload

    # Manually update live edition. Whether the latest edition
    # is published or draft, this will create a new draft with
    # an `update_type: "republish"`. We then need to publish it.
    GdsApi.publishing_api_v2.put_content(
      document.content_id,
      payload.merge(update_type: "republish", bulk_publishing: true),
    )

    # Manually publish assets to live stack before we publish
    # the document, otherwise we risk referencing assets that
    # aren't visible yet.
    PublishAssetService.call(document.live_edition, nil)

    GdsApi.publishing_api_v2.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )
  end

  def update_draft_edition
    # Present to publishing API & Asset Manager draft stack
    PreviewService.call(document.current_edition)
  end
end
