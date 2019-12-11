# frozen_string_literal: true

class EditionsController < ApplicationController
  before_action :check_permissions

  def create
    Editions::CreateInteractor.call(params: params, user: current_user)
    redirect_to edit_document_path(params[:document])
  end

private

  def check_permissions
    @edition = Edition.find_current(document: params[:document])
    return if !@edition.history_mode? || current_user.has_permission?(User::MANAGE_LIVE_HISTORY_MODE)

    render "missing_permissions/update_history_mode", status: :forbidden
  end
end
