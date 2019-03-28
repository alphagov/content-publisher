# frozen_string_literal: true

class PublishController < ApplicationController
  def confirmation
    @edition = Edition.find_current(document: params[:document])

    issues = Requirements::EditionChecker.new(@edition)
                                         .pre_publish_issues(rescue_api_errors: false)

    if issues.any?
      redirect_to document_path(@edition.document), tried_to_publish: true
      return
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to @edition.document,
                alert_with_description: t("documents.show.flashes.publish_error")
  end

  def publish
    edition = Edition.find_current(document: params[:document])
    live_edition = nil

    Edition.transaction do
      edition.lock!

      if params[:review_status].blank?
        flash.now["alert_with_items"] = {
          "title" => I18n.t!("publish.confirmation.flashes.requirements"),
          "items" => review_status_issues.items,
        }

        render :confirmation,
               assigns: { issues: review_status_issues, edition: edition },
               status: :unprocessable_entity
        return
      end

      if edition.live?
        redirect_to published_path(edition.document)
        return
      end

      with_review = params[:review_status] == "reviewed"

      begin
        live_edition = PublishService.new(edition.document)
                                     .publish(user: current_user, with_review: with_review)
      rescue GdsApi::BaseError
        redirect_to edition.document, alert_with_description: t("documents.show.flashes.publish_error")
        return
      end

      TimelineEntry.create_for_status_change(
        entry_type: with_review ? :published : :published_without_review,
        status: live_edition.status,
      )
    end

    send_notifications(live_edition)
    redirect_to published_path(edition.document)
  end

  def published
    @edition = Edition.find_current(document: params[:document])
  end

private

  def review_status_issues
    @review_status_issues ||= Requirements::CheckerIssues.new([
      Requirements::Issue.new(:review_status, :not_selected),
    ])
  end

  def send_notifications(edition)
    edition.editors.each do |user|
      PublishMailer.publish_email(edition, user).deliver_later
    end
  end
end
