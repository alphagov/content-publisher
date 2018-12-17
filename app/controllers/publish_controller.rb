# frozen_string_literal: true

class PublishController < ApplicationController
  def confirmation
    @document = Document.find_by_param(params[:id])

    if Requirements::DocumentChecker.new(@document).pre_publish_issues(rescue_api_errors: false).any?
      redirect_to document_path(@document), tried_to_publish: true
      return
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to @document, alert_with_description: t("documents.show.flashes.publish_error")
  end

  def publish
    document = Document.find_by_param(params[:id])
    review_state = params[:self_declared_review_state] == "has-been-reviewed" ? "reviewed" : "published_without_review"
    PublishService.new(document).publish(review_state)

    if review_state == "reviewed"
      TimelineEntry.create!(document: document, user: current_user, entry_type: "published")
    else
      TimelineEntry.create!(document: document, user: current_user, entry_type: "published_without_review")
    end

    redirect_to published_path(document)
  rescue GdsApi::BaseError
    redirect_to document, alert_with_description: t("documents.show.flashes.publish_error")
  end

  def published
    @document = Document.find_by_param(params[:id])
  end
end
