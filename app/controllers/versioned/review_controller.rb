# frozen_string_literal: true

module Versioned
  class ReviewController < ApplicationController
    def submit_for_2i
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        issues = Versioned::Requirements::EditionChecker
          .new(document.current_edition)
          .pre_publish_issues(rescue_api_errors: false)

        if issues.any?
          redirect_to versioned_document_path(document), tried_to_publish: true
          return
        end

        document.current_edition
                .assign_status(current_user, :submitted_for_review)
                .save!

        # TimelineEntry.create!(document: document, user: current_user, entry_type: "submitted")
        flash[:submitted_for_review] = true
        redirect_to document
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to document, alert_with_description: t("documents.show.flashes.2i_error")
      end
    end

    # def approve
    #   Versioned::Document.transaction do
    #     document = Versioned::Document.with_current_edition
    #                                   .lock
    #                                   .find_by_param(params[:id])
    #     # TimelineEntry.create!(document: document, user: current_user, entry_type: "approved")
    #     redirect_to document, notice: t("documents.show.flashes.approved")
    #   end
    # end
  end
end
