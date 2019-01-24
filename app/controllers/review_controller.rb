# frozen_string_literal: true

class ReviewController < ApplicationController
  def submit_for_2i
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])
      current_edition = document.current_edition

      begin
        issues = Requirements::EditionChecker.new(current_edition)
                                             .pre_publish_issues(rescue_api_errors: false)

        if issues.any?
          redirect_to document_path(document), tried_to_publish: true
          return
        end

        current_edition.assign_status(:submitted_for_review, current_user).save!

        TimelineEntry.create_for_status_change(entry_type: :submitted,
                                               status: current_edition.status)

        flash[:submitted_for_review] = true
        redirect_to document
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to document, alert_with_description: t("documents.show.flashes.2i_error")
      end
    end
  end

  def approve
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])

      current_edition = document.current_edition

      if !current_edition.status.published_but_needs_2i?
        # FIXME: this shouldn't be an exception but we've not worked out the
        # right response - maybe bad request or a redirect with flash?
        raise "Can't approve a document that doesn't need 2i"
      end

      current_edition.assign_status(:published, current_user).save!

      TimelineEntry.create_for_status_change(entry_type: :approved,
                                             status: current_edition.status)

      redirect_to document, notice: t("documents.show.flashes.approved")
    end
  end
end
