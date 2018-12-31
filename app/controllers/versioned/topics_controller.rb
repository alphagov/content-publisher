# frozen_string_literal: true

module Versioned
  class TopicsController < ApplicationController
    rescue_from GdsApi::BaseError do |e|
      GovukError.notify(e)
      render "#{action_name}_api_down", status: :service_unavailable
    end

    def edit
      @document = Versioned::Document.with_current_edition
                                     .find_by_param(params[:document_id])
      @version = @document.document_topics.version
      @topics = @document.topics
    end

    def update
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:document_id])

        document.document_topics.patch(params.fetch(:topics, []), params[:version].to_i)

        redirect_to versioned_document_path(document), notice: t("documents.show.flashes.topics_updated")
      rescue GdsApi::HTTPConflict
        Rails.logger.warn("Conflict updating topics for #{document.content_id} at version #{params[:version].to_i}")
        redirect_to versioned_topics_path(document), alert_with_description: t("topics.edit.flashes.topic_update_conflict")
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to document, alert_with_description: t("documents.show.flashes.topic_update_error")
      end
    end
  end
end
