# frozen_string_literal: true

class FileAttachments::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_remove_attachment
      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def find_and_remove_attachment
    context.attachment_revision = edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.remove_file_attachment(attachment_revision)
    edition.assign_revision(updater.next_revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_deleted, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
