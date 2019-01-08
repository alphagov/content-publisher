# frozen_string_literal: true

module Versioned
  class TagsController < ApplicationController
    rescue_from GdsApi::BaseError do |e|
      GovukError.notify(e)
      render "#{action_name}_api_down", status: :service_unavailable
    end

    def edit
      @document = Versioned::Document.with_current_edition
                                     .find_by_param(params[:id])
      @revision = @document.current_edition.revision
    end

    def update
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:id])

        current_edition = document.current_edition

        revision = current_edition.build_next_revision(
          { tags: update_params(document) },
          current_user,
        )

        current_edition.update!(revision: revision)
        current_edition.update_last_edited_at(current_user)

        Versioned::TimelineEntry.create_for_revision(
          entry_type: :updated_tags,
          edition: current_edition,
        )

        PreviewService.new(current_edition).try_create_preview

        redirect_to document
      end
    end

  private

    def update_params(document)
      permits = document.document_type.tags.map do |tag_field|
        [tag_field.id, []]
      end

      params.fetch(:tags, {}).permit(Hash[permits])
    end
  end
end
