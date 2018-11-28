# frozen_string_literal: true

class ReviewController < ApplicationController
  def submit_for_2i
    document = Document.find_by_param(params[:id])

    if Requirements::DocumentChecker.new(document).pre_publish_issues(rescue_api_errors: false).any?
      redirect_to document_path(document), tried_to_publish: true
      return
    end

    document.update!(review_state: "submitted_for_review")
    TimelineEntry.create!(document: document, user: current_user, entry_type: "submitted")
    flash[:submitted_for_review] = true
    redirect_to document
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document, alert_with_description: t("documents.show.flashes.2i_error")
  end

  def approve
    document = Document.find_by_param(params[:id])
    document.update!(review_state: "reviewed")
    TimelineEntry.create!(document: document, user: current_user, entry_type: "approved")
    redirect_to document, notice: t("documents.show.flashes.approved")
  end
end
