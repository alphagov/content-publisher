# frozen_string_literal: true

class InternalNotesController < ApplicationController
  def create
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      note = params.fetch(:internal_note)

      if note&.chomp.blank?
        redirect_to_document_history(edition)
        next
      end

      internal_note = InternalNote.create!(
        body: note,
        edition: edition,
        created_by: current_user,
      )

      TimelineEntry.create_for_revision(
        entry_type: :internal_note,
        edition: edition,
        details: internal_note,
        created_by: current_user,
      )

      redirect_to_document_history(edition)
    end
  end

private

  def redirect_to_document_history(edition)
    redirect_to(document_path(edition.document), anchor: "document-history")
  end
end
