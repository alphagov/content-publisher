# frozen_string_literal: true

class DocumentTagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.find_by_param(params[:id])
  end

  def update
    document = Document.find_by_param(params[:id])
    document.update!(tags: update_params(document))
    TimelineEntry.create!(document: document, user: current_user, entry_type: "updated_tags")
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

private

  def update_params(document)
    permits = document.document_type_schema.tags.map do |schema|
      [schema.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits])
  end
end
