# frozen_string_literal: true

class TopicsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    @version = @edition.document_topics.version
    @topics = @edition.topics
  end

  def update
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      begin
        edition.document_topics.patch(params.fetch(:topics, []), params[:version].to_i)

        redirect_to document_path(edition.document),
                    notice: t("documents.show.flashes.topics_updated")
      rescue GdsApi::HTTPConflict
        Rails.logger.warn("Conflict updating topics for #{edition.content_id} at version #{params[:version].to_i}")
        redirect_to topics_path(edition.document),
                    alert_with_description: t("topics.edit.flashes.topic_update_conflict")
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to edition.document,
                    alert_with_description: t("documents.show.flashes.topic_update_error")
      end
    end
  end
end
