class InternalNotesController < ApplicationController
  def create
    InternalNotes::CreateInteractor.call(params:, user: current_user)
    redirect_to document_history_path(params[:document])
  end
end
