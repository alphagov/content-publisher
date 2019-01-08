# frozen_string_literal: true

module Versioned
  class EditionsController < ApplicationController
    def create
      Versioned::Document.transaction do # rubocop:disable Metrics/BlockLength
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:document_id])
        current_edition = document.current_edition

        if !current_edition.live
          # This should probably be a bad request
          redirect_to document
          return
        end

        current_edition.update!(current: false)

        next_edition = Versioned::Edition.find_by(
          document: document,
          number: current_edition.number + 1,
        )

        if next_edition
          next_edition.resume_discarded(current_edition, current_user)

          Versioned::TimelineEntry.create_for_status_change(
            entry_type: :draft_reset,
            status: next_edition.status,
          )
        else
          next_edition = Versioned::Edition.create_next_edition(current_edition, current_user)

          Versioned::TimelineEntry.create_for_status_change(
            entry_type: :new_edition,
            status: next_edition.status,
          )
        end

        Versioned::PreviewService.new(next_edition).try_create_preview

        redirect_to versioned_edit_document_path(document)
      end
    end
  end
end
