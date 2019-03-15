# frozen_string_literal: true

class ReviewController < ApplicationController
  def submit_for_2i
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      begin
        issues = Requirements::EditionChecker.new(edition)
                                             .pre_publish_issues(rescue_api_errors: false)
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to edition.document, alert_with_description: t("documents.show.flashes.2i_error")
        next
      end

      if issues.any?
        redirect_to document_path(edition.document), tried_to_publish: true
        next
      end

      edition.assign_status(:submitted_for_review, current_user).save!

      TimelineEntry.create_for_status_change(entry_type: :submitted,
                                             status: edition.status)

      flash[:submitted_for_review] = true
      redirect_to edition.document
    end
  end

  def approve
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      if !edition.status.published_but_needs_2i?
        # FIXME: this shouldn't be an exception but we've not worked out the
        # right response - maybe bad request or a redirect with flash?
        raise "Can't approve a document that doesn't need 2i"
      end

      edition.assign_status(:published, current_user).save!

      TimelineEntry.create_for_status_change(entry_type: :approved,
                                             status: edition.status)

      redirect_to edition.document, notice: t("documents.show.flashes.approved")
    end
  end
end
