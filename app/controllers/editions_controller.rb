# frozen_string_literal: true

class EditionsController < ApplicationController
  def create
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:document_id])

      current_edition = document.current_edition

      unless current_edition.live?
        # This should probably be a bad request
        redirect_to document
        return
      end

      current_edition.update!(current: false)

      next_edition = Edition.find_by(
        document: document,
        number: current_edition.number + 1,
      )

      if next_edition
        next_edition.resume_discarded(current_edition, current_user)

        TimelineEntry.create_for_status_change(entry_type: :draft_reset,
                                               status: next_edition.status)
      else
        next_edition = Edition.create_next_edition(current_edition, current_user)

        TimelineEntry.create_for_status_change(entry_type: :new_edition,
                                               status: next_edition.status)
      end

      PreviewService.new(next_edition).try_create_preview

      redirect_to edit_document_path(document)
    end
  end
end
