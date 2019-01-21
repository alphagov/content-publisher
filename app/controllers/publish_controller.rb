# frozen_string_literal: true

class PublishController < ApplicationController
  def confirmation
    @document = Document.with_current_edition.find_by_param(params[:id])

    issues = Requirements::EditionChecker.new(@document.current_edition)
                                         .pre_publish_issues(rescue_api_errors: false)

    if issues.any?
      redirect_to document_path(@document), tried_to_publish: true
      return
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to @document, alert_with_description: t("documents.show.flashes.publish_error")
  end

  def publish
    Document.transaction do
      @document = Document.with_current_edition.lock.find_by_param(params[:id])

      if @document.current_edition.live
        redirect_to published_path(@document)
        return
      end

      with_review = params[:review_state] == "reviewed"

      live_edition = PublishService.new(@document).publish(user: current_user,
                                                           with_review: with_review)

      TimelineEntry.create_for_status_change(
        entry_type: with_review ? :published : :published_without_review,
        status: live_edition.status,
      )

      redirect_to published_path(@document)
    end
  rescue GdsApi::BaseError
    redirect_to @document, alert_with_description: t("documents.show.flashes.publish_error")
  end

  def published
    document = Document.with_current_edition.find_by_param(params[:id])
    @edition = document.current_edition
  end
end
