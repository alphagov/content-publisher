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
    document.assign_attributes(tags: update_params(document))

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "updated_tags",
    )

    redirect_to document
  end

private

  def update_params(document)
    permits = document.document_type.tags.map do |tag_field|
      [tag_field.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits])
  end
end
