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
    @topic_index = TopicsService.new.topic_index
    @topic_content_ids = TopicsService.new.topics_for_document(@document)
  end

  def update
    document = Document.find_by_param(params[:document_id])
    TopicsService.new.patch_topics(document, params.fetch(:topics, {}))
    redirect_to document_path(document), notice: t("documents.show.flashes.topics_updated")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to document, alert_with_description: t("documents.show.flashes.topic_update_error")
  end
end
