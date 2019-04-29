# frozen_string_literal: true

class PreviewController < ApplicationController
  def create
    result = Preview::CreateInteractor.call(params: params, user: current_user)
    issues, preview_failed = result.to_h.values_at(:issues, :preview_failed)

    if issues
      redirect_to document_path(params[:document]), tried_to_preview: true
    elsif preview_failed
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.preview_error")
    else
      redirect_to preview_document_path(params[:document])
    end
  end

  def show
    @edition = Edition.find_current(document: params[:document])
  end
end
