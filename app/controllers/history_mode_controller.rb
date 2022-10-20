class HistoryModeController < ApplicationController
  before_action :check_permission

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
  end

  def update
    result = HistoryMode::UpdateInteractor.call(params:, user: current_user)
    redirect_to document_path(result.edition.document)
  end

  def check_permission
    return if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)

    @edition = Edition.find_current(document: params[:document])
    render :non_managing_editor, status: :forbidden
  end
end
