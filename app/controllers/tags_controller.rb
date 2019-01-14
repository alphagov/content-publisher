# frozen_string_literal: true

class TagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.with_current_edition.find_by_param(params[:id])
    @revision = @document.current_edition.revision
  end

  def update
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])

      current_edition = document.current_edition

      revision = current_edition.build_revision_update(
        { tags: update_params(document) },
        current_user,
      )

      if revision != current_edition.revision
        current_edition.assign_revision(revision, current_user).save!

        TimelineEntry.create_for_revision(entry_type: :updated_tags,
                                          edition: current_edition)

        PreviewService.new(current_edition).try_create_preview
      end

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
