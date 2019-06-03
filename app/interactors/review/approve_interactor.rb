# frozen_string_literal: true

class Review::ApproveInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_status

      approve_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_status
    context.fail!(wrong_status: true) unless edition.published_but_needs_2i?
  end

  def approve_edition
    edition.assign_status(:published, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :approved,
                                           status: edition.status)
  end
end
