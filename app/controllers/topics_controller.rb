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
    result = Topics::UpdateInteractor.call(params: params, user: current_user)
    api_conflict, api_error = result.to_h.values_at(:api_conflict, :api_error)

    if api_conflict
      redirect_to topics_path(params[:document]),
                  alert_with_description: t("topics.edit.flashes.topic_update_conflict")
    elsif api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.topic_update_error")
    else
      redirect_to document_path(params[:document]),
                  notice: t("documents.show.flashes.topics_updated")
    end
  end
end
