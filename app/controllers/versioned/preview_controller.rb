# frozen_string_literal: true

module Versioned
  class PreviewController < ApplicationController
    def create
      Versioned::Document.transaction do
        @document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        if Versioned::Requirements::EditionChecker.new(@document.current_edition).pre_preview_issues.any?
          redirect_to versioned_document_path(@document), tried_to_preview: true
          return
        end

        Versioned::PreviewService.new(@document.current_edition).create_preview

        redirect_to versioned_preview_document_path(@document)
      end
    rescue GdsApi::BaseError => e
      GovukError.notify(e)
      redirect_to versioned_document_path(@document), alert_with_description: t("documents.show.flashes.preview_error")
    end

    def show
      @document = Versioned::Document.with_current_edition.find_by_param(params[:id])
    end
  end
end
