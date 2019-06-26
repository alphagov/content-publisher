# frozen_string_literal: true

class PublishService
  attr_reader :edition
  delegate :document, to: :edition

  def initialize(edition)
    @edition = edition
  end

  def publish(user:, with_review:)
    live_edition = document.live_edition

    PublishAssetService.new.publish_assets(edition, live_edition)

    GdsApi.publishing_api_v2.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )

    supersede_live_edition(live_edition, user)
    set_new_live_edition(user, with_review)
    set_first_published_at

    document.reload
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def supersede_live_edition(live_edition, user)
    return unless live_edition

    live_edition.assign_status(:superseded, user, update_last_edited: false)
    live_edition.live = false
    live_edition.save!
  end

  def set_new_live_edition(user, with_review)
    status = with_review ? :published : :published_but_needs_2i
    edition.remove_access_limit(user) if edition.access_limit
    edition.assign_status(status, user)
    edition.live = true
    edition.save!
  end

  def set_first_published_at
    return if document.first_published_at

    document.update!(first_published_at: Time.current)
  end
end
