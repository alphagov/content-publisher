# frozen_string_literal: true

class PublishController < ApplicationController
  def confirmation
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

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
    result = Publish::PublishInteractor.call(params: params, user: current_user)

    edition, issues, publish_failed = result.to_h.values_at(:edition,
                                                            :issues,
                                                            :publish_failed)
    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :confirmation,
             assigns: { issues: issues, edition: edition },
             status: :unprocessable_entity
    elsif publish_failed
      redirect_to edition.document,
                  alert_with_description: t("documents.show.flashes.publish_error")
    else
      redirect_to published_path(params[:document])
    end
  end

  def published
    @edition = Edition.find_current(document: params[:document])
  end
end
