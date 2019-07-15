# frozen_string_literal: true

class Schedule::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :edition,
           :user,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition
      destroy_publish_intent
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:scheduled?)
  end

  def update_edition
    scheduling = edition.status.details

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(proposed_publish_time: scheduling.publish_time)

    state = scheduling.reviewed? ? :submitted_for_review : :draft

    edition.assign_revision(updater.next_revision, user)
           .assign_status(state, user)
           .save!
  end

  def destroy_publish_intent
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
