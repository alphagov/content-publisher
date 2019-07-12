# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def confirm
    @edition = Edition.find_current(document: params[:document])
    assert_permission(current_user, User::MANAGING_EDITOR_PERMISSION)
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
end
