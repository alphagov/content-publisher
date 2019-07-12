# frozen_string_literal: true

class EditionsController < ApplicationController
  def create
    Editions::CreateInteractor.call(params: params, user: current_user)
    redirect_to edit_document_path(params[:document])
  end
end
