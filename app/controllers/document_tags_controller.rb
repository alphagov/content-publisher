# frozen_string_literal: true

class DocumentTagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.find_by_param(params[:id])
  end

  def update
    document = Document.find_by_param(params[:id])
    document.assign_attributes(tags: update_params(document))

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "updated_tags",
    )

    redirect_to document
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to document, alert_with_description: t("documents.show.flashes.draft_error")
  end

private

  def update_params(document)
    permits = document.document_type_schema.tags.map do |schema|
      [schema.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits])
  end
end
