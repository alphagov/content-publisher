# frozen_string_literal: true

class EditionsController < ApplicationController
  def create
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      unless edition.live?
        # FIXME: this shouldn't be an exception but we've not worked out the
        # right response - maybe bad request or a redirect with flash?
        raise "Can't create a new edition when the current edition is a draft"
      end

      edition.update!(current: false)

      next_edition = Edition.find_by(
        document: edition.document,
        number: edition.number + 1,
      )

      if next_edition
        next_edition.resume_discarded(edition, current_user)

        TimelineEntry.create_for_status_change(entry_type: :draft_reset,
                                               status: next_edition.status)
      else
        next_edition = Edition.create_next_edition(edition, current_user)

        TimelineEntry.create_for_status_change(entry_type: :new_edition,
                                               status: next_edition.status)
      end

      PreviewService.new(next_edition).try_create_preview

      redirect_to edit_document_path(next_edition.document)
    end
  end
end
