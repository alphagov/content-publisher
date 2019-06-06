# frozen_string_literal: true

class ScheduleProposal::DestroyInteractor
  include Interactor
  delegate :params,
           :edition,
           :user,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      clear_scheduled_publishing_datetime
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def clear_scheduled_publishing_datetime
    context.fail! unless edition.editable?

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(scheduled_publishing_datetime: nil)

    if updater.changed?
      edition.assign_revision(updater.next_revision, user).save!
    end
  end
end
