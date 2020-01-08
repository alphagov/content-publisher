# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  before_action :check_permissions

  def confirm
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:withdrawn?)
  end

  def unwithdraw
    result = Unwithdraw::UnwithdrawInteractor.call(params: params, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.unwithdraw_error")
    else
      redirect_to document_path(params[:document])
    end
  end

private

  def check_permissions
    @edition = Edition.find_current(document: params[:document])

    if !current_user.has_permission?(User::MANAGE_LIVE_HISTORY_MODE) && @edition.history_mode?
      render "missing_permissions/update_history_mode", status: :forbidden
      return
    end

    if !current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      render :non_managing_editor, status: :forbidden
    end
  end
end
