# frozen_string_literal: true

class PreviewController < ApplicationController
  def create
    Document.transaction do
      @document = Document.with_current_edition.lock.find_by_param(params[:id])

      if Requirements::EditionChecker.new(@document.current_edition).pre_preview_issues.any?
        redirect_to document_path(@document), tried_to_preview: true
        return
      end

      PreviewService.new(@document.current_edition).create_preview

      redirect_to preview_document_path(@document)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document_path(@document), alert_with_description: t("documents.show.flashes.preview_error")
  end

  def show
    @document = Document.with_current_edition.find_by_param(params[:id])
  end
end
