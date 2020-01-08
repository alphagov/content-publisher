# frozen_string_literal: true

class PublishController < ApplicationController
  def confirmation
    result = Publish::ConfirmationInteractor.call(params: params, user: current_user)
    @edition, issues, api_error = result.to_h.values_at(:edition, :issues, :api_error)

    if issues
      redirect_to document_path(@edition.document), tried_to_publish: true
    elsif api_error
      redirect_to document_path(@edition.document),
                  alert_with_description: t("documents.show.flashes.publish_error")
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
      redirect_to document_path(edition.document),
                  alert_with_description: t("documents.show.flashes.publish_error")
    else
      redirect_to published_path(edition.document)
    end
  end

  def published
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
  end
end
