class Review::ApproveInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :wrong_status,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      approve_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:published_but_needs_2i?)
  end

  def approve_edition
    AssignEditionStatusService.call(edition, user:, state: :published)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :approved,
                                           status: edition.status)
  end
end
