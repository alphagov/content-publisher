class Editions::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :next_edition,
           :discarded_edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      create_next_edition
      create_timeline_entry
      preview_next_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    context.discarded_edition = Edition.find_by(document: edition.document,
                                                number: edition.number + 1)
    assert_edition_state(edition, assertion: "can create new edition") { edition.live }
  end

  def create_next_edition
    context.next_edition = CreateNextEditionService.call(current_edition: edition,
                                                         user: user,
                                                         discarded_edition: discarded_edition)
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

  def preview_next_edition
    FailsafeDraftPreviewService.call(next_edition)
  end
end
