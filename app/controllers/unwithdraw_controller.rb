# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def confirm
    @document = Document.with_current_edition.find_by_param(params[:id])

    if !current_user.has_permission?(User::PRE_RELEASE_FEATURES_PERMISSION)
      render :non_pre_release
      return
    end

    if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      redirect_to document_path(@document), confirmation: "unwithdraw/confirm"
    else
      render :non_managing_editor
    end
  end

  def unwithdraw
    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      edition = document.current_edition

      begin
        UnwithdrawService.new.call(edition, current_user)
        redirect_to document
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to document, alert_with_description: t("documents.show.flashes.unwithdraw_error")
      end
    end
  end
end
