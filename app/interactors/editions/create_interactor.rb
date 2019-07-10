# frozen_string_literal: true

class Editions::CreateInteractor
  include Interactor
  delegate :params,
           :user,
           :live_edition,
           :next_edition,
           :draft_current_edition,
           :discarded_edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_live_edition
      create_next_edition
      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_live_edition
    edition = Edition.lock.find_current(document: params[:document])

    unless edition.live?
      raise "Can't create a new edition when the current edition is a draft"
    end

    context.live_edition = edition
  end

  def create_next_edition
    live_edition.update!(current: false)

    context.discarded_edition = Edition.find_by(
      document: live_edition.document,
      number: live_edition.number + 1,
    )

    discarded_edition.resume_discarded(live_edition, user) if discarded_edition
    context.next_edition = discarded_edition || Edition.create_next_edition(live_edition, user)
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

  def update_preview
    PreviewService.new(live_edition).try_create_preview
  end
end
