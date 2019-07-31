# frozen_string_literal: true

class Documents::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :api_error,
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
    assert_edition_state(edition, &:editable?)
  end

  def discard_draft
    DeleteDraftService.new(edition.document, user).delete
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :draft_discarded,
                                           status: edition.status)
  end
end
