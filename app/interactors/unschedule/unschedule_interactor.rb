# frozen_string_literal: true

class Unschedule::UnscheduleInteractor
  include Interactor

  delegate :params, :edition, :user, to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      set_edition_status
      destroy_publishing_intent
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    context.fail! unless edition.scheduled?
  end

  def set_edition_status
    scheduling = edition.status.details
    state = scheduling.reviewed? ? :submitted_for_review : :draft
    edition.assign_status(state, user).save!
  end

  def destroy_publishing_intent
    GdsApi.publishing_api.destroy_intent(edition.base_path)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: :unscheduled,
      status: edition.status,
    )
  end
end
