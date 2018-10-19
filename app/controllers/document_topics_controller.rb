# frozen_string_literal: true

class DocumentTopicsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @tree = TopicsService.new.tree
  end
end
