# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def confirm
    @edition = Edition.find_current(document: params[:document])

    if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      redirect_to document_path(@edition.document), confirmation: "unwithdraw/confirm"
    else
      render :non_managing_editor
    end
  end

  def unwithdraw
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      UnwithdrawService.new.call(edition, current_user)
      redirect_to edition.document
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document_path(params[:document]),
      alert_with_description: t("documents.show.flashes.unwithdraw_error")
  end
end
