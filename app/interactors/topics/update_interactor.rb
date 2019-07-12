# frozen_string_literal: true

class Topics::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :document,
           :api_conflict,
           :api_error,
           to: :context

  def call
    find_document
    update_topics
  end

private

  def find_document
    context.document = Document.with_current_edition.find_by_param(params[:document])
  end

  def update_topics
    document.document_topics.patch(params.fetch(:topics, []), params[:version].to_i)
  rescue GdsApi::HTTPConflict
    Rails.logger.warn("Conflict updating topics for #{document.content_id} at version #{params[:version].to_i}")
    context.fail!(api_conflict: true)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end
end
