# frozen_string_literal: true

class Documents::DestroyInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :api_errored,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      discard_draft
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def discard_draft
    DeleteDraftService.new(edition.document, user).delete
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_errored: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :draft_discarded,
                                           status: edition.status)
  end
end
