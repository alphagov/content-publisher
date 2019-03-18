# frozen_string_literal: true

class TagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.assign(tags: update_params(edition))

      if updater.changed?
        edition.assign_revision(updater.next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :updated_tags, edition: edition)
        PreviewService.new(edition).try_create_preview
      end

      redirect_to edition.document
    end
  end

private

  def update_params(edition)
    permits = edition.document_type.tags.map do |tag_field|
      [tag_field.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits])
  end
end
