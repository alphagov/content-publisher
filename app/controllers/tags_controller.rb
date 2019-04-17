# frozen_string_literal: true

class TagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    Tags::UpdateInteractor.call(params: params, user: current_user)
    redirect_to document_path(params[:document])
  end

private

  def update_params(edition)
    permits = edition.document_type.tags.map do |tag_field|
      [tag_field.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits])
  end
end
