# frozen_string_literal: true

class PreviewController < ApplicationController
  def create
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      begin
        if Requirements::EditionChecker.new(edition).pre_preview_issues.any?
          redirect_to document_path(edition.document), tried_to_preview: true
          next
        end

        PreviewService.new(edition).create_preview
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to document_path(edition.document),
                    alert_with_description: t("documents.show.flashes.preview_error")
        next
      end

      redirect_to preview_document_path(edition.document)
    end
  end

  def show
    @edition = Edition.find_current(document: params[:document])
  end
end
