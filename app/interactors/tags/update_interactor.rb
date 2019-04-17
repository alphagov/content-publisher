# frozen_string_literal: true

class Tags::UpdateInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           :unchanged,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition

      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(tags: update_params(edition))

    if updater.changed?
      edition.assign_revision(updater.next_revision, user).save!
    else
      context.fail!(unchanged: true)
    end
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_tags, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end

  def update_params(edition)
    permits = edition.document_type.tags.map do |tag_field|
      [tag_field.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits])
  end
end
