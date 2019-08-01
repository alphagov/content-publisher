# frozen_string_literal: true

class Editions::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :next_edition,
           :discarded_edition,
           :next_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      create_next_revision
      create_next_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])

    assert_edition_state(edition, assertion: "can create new edition") do
      edition.live || edition.discarded?
    end
  end

  def create_next_revision
    updater = Versioning::RevisionUpdater.new(edition.revision, user)

    updater.assign(change_note: "",
                   update_type: "major",
                   proposed_publish_time: nil)

    context.next_revision = updater.next_revision
  end

  def create_next_edition
    edition.update!(current: false)

    context.discarded_edition = Edition.find_by(
      document: edition.document,
      number: edition.number + 1,
    )

    context.next_edition = discarded_edition ||
      Edition.new(document: edition.document,
                  number: edition.document.next_edition_number,
                  created_by: user)

    next_edition.assign_as_edit(user, current: true, revision: next_revision)
    next_edition.assign_status(:draft, user).save!
  end

  def create_timeline_entry
    if discarded_edition
      TimelineEntry.create_for_status_change(entry_type: :draft_reset,
                                             status: next_edition.status)
    else
      TimelineEntry.create_for_status_change(entry_type: :new_edition,
                                             status: next_edition.status)
    end
  end
end
