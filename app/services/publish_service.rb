# frozen_string_literal: true

class PublishService < ApplicationService
  def initialize(edition, user, with_review:)
    @edition = edition
    @user = user
    @with_review = with_review
  end

  def call
    live_edition = document.live_edition
    publish_assets(live_edition)
    publish_current_edition
    supersede_live_edition(live_edition)
    set_new_live_edition
    set_first_published_at
    document.reload
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  attr_reader :edition, :user, :with_review
  delegate :document, to: :edition

  def publish_assets(live_edition)
    PublishAssetService.call(edition, live_edition)
  end

  def publish_current_edition
    GdsApi.publishing_api_v2.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )
  end

  def supersede_live_edition(live_edition)
    return unless live_edition

    live_edition.assign_status(:superseded, user, update_last_edited: false)
    live_edition.live = false
    live_edition.save!
  end

  def set_new_live_edition
    status = with_review ? :published : :published_but_needs_2i
    edition.assign_as_edit(user, access_limit: nil)
    edition.assign_status(status, user)
    edition.live = true
    edition.save!
  end

  def set_first_published_at
    return if document.first_published_at

    document.update!(first_published_at: Time.current)
  end
end
