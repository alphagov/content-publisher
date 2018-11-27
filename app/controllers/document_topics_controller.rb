# frozen_string_literal: true

class DocumentTopicsController < ApplicationController
  include GDS::SSO::ControllerMethods

  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @version = @document.document_topics.version
    @topics = @document.topics
  end

  def update
    document = Document.find_by_param(params[:document_id])
    document.document_topics.patch(params.fetch(:topics, []), params[:version].to_i)
    redirect_to document_path(document), notice: t("documents.show.flashes.topics_updated")
  rescue GdsApi::HTTPConflict => e
    Rails.logger.error(e)
    redirect_to document_topics_path, alert_with_description: t("document_topics.edit.flashes.topic_update_conflict")
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document, alert_with_description: t("documents.show.flashes.topic_update_error")
  end
end
