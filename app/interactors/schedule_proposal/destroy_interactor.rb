# frozen_string_literal: true

class ScheduleProposal::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :edition,
           :user,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      clear_proposed_time
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def clear_proposed_time
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(proposed_publish_time: nil)

    if updater.changed?
      edition.assign_revision(updater.next_revision, user).save!
    end
  end
end
