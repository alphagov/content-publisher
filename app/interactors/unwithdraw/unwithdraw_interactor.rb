# frozen_string_literal: true

class Unwithdraw::UnwithdrawInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :api_error,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition
      create_timeline_entry
      republish_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:withdrawn?)
  end

  def update_edition
    withdrawal = edition.status.details
    published_status = withdrawal.published_status

    edition.assign_status(published_status.state, user)
    edition.save!
  end

  def republish_edition
    GdsApi.publishing_api_v2.republish(edition.content_id, locale: "en")
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: :unwithdrawn,
      status: edition.status,
    )
  end
end
