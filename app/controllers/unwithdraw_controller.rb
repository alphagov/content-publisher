# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  before_action :check_permission

  def confirm
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:withdrawn?)
    redirect_to document_path(@edition.document), confirmation: "unwithdraw/confirm"
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

  def check_permission
    return if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)

    @edition = Edition.find_current(document: params[:document])
    render :non_managing_editor, status: :forbidden
  end
end
