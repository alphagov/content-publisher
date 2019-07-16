# frozen_string_literal: true

class PublishController < ApplicationController
  def confirmation
    result = Publish::ConfirmationInteractor.call(params: params, user: current_user)
    issues, edition, api_error = result.to_h.values_at(:issues, :edition, :api_error)

    if issues
      redirect_to document_path(edition.document), tried_to_publish: true
    elsif api_error
      redirect_to edition.document,
                  alert_with_description: t("documents.show.flashes.publish_error")
    else
      @edition = edition
    end
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
