# frozen_string_literal: true

class InternalNotesController < ApplicationController
  include GDS::SSO::ControllerMethods
  before_action { authorise_user!(User::PRE_RELEASE_FEATURES_PERMISSION) }

  def create
    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      note = params.fetch(:internal_note)

      if note&.chomp.blank?
        return redirect_to_document_history(document)
      end

      internal_note = InternalNote.create!(
        body: note,
        edition: document.current_edition,
        created_by: current_user,
      )

      TimelineEntry.create_for_revision(
        entry_type: :internal_note,
        edition: document.current_edition,
        details: internal_note,
        created_by: current_user,
      )

      redirect_to_document_history(document)
    end
  end

private

  def redirect_to_document_history(document)
    redirect_to("#{document_path(document)}#document-history")
  end
end
