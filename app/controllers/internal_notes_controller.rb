# frozen_string_literal: true

class InternalNotesController < ApplicationController
  def create
    InternalNotes::CreateInteractor.call(params: params, user: current_user)
    redirect_to document_history_path(params[:document])
  end
end
