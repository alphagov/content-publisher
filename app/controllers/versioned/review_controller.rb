# frozen_string_literal: true

module Versioned
  class ReviewController < BaseController
    def submit_for_2i
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        begin
          issues = Versioned::Requirements::EditionChecker
            .new(document.current_edition)
            .pre_publish_issues(rescue_api_errors: false)

          if issues.any?
            redirect_to versioned_document_path(document), tried_to_publish: true
            return
          end

          document.current_edition
                  .assign_status(:submitted_for_review, current_user)
                  .save!

          Versioned::TimelineEntry.create_for_status_change(
            entry_type: :submitted,
            status: document.current_edition.status,
          )

          flash[:submitted_for_review] = true
          redirect_to document
        rescue GdsApi::BaseError => e
          GovukError.notify(e)
          redirect_to document, alert_with_description: t("documents.show.flashes.2i_error")
        end
      end
    end

    def approve
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        current_edition = document.current_edition

        if !current_edition.status.published_but_needs_2i?
          # probably better to return a 400 response but we don't currently
          # have a template
          redirect_to document
        end

        current_edition.assign_status(:published, current_user)
        current_edition.save!

        Versioned::TimelineEntry.create_for_status_change(
          entry_type: :approved,
          status: document.current_edition.status,
        )

        redirect_to document, notice: t("documents.show.flashes.approved")
      end
    end
  end
end
