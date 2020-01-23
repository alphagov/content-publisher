# frozen_string_literal: true

class EditionsController < ApplicationController
  before_action :check_permissions

  def create
    Editions::CreateInteractor.call(params: params, user: current_user)
    redirect_to content_path(params[:document])
  end

  def destroy_draft
    result = Editions::DestroyInteractor.call(params: params, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.delete_draft_error")
    else
      redirect_to documents_path
    end
  end

  def confirm_delete_draft
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
  end

private

  def check_permissions
    @edition = Edition.find_current(document: params[:document])
    return if !@edition.history_mode? || current_user.has_permission?(User::MANAGE_LIVE_HISTORY_MODE)

    render "missing_permissions/update_history_mode", status: :forbidden
  end
end
