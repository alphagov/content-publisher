# frozen_string_literal: true

class DocumentTopicsController < ApplicationController
  include GDS::SSO::ControllerMethods
  before_action { authorise_user!(User::PRE_RELEASE_FEATURES_PERMISSION) }

  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @topics = TopicsService.new.topics
  end
end
