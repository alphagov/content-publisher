# frozen_string_literal: true

class FileAttachments::UpdateInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           :file_attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_file_attachment
      check_for_issues

      update_file_attachment
      update_edition

      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def find_file_attachment
    context.file_attachment_revision = edition.file_attachment_revisions
                                              .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def check_for_issues
    checker = Requirements::FileAttachmentChecker.new(file: attachment_params[:file],
                                                      title: attachment_params[:title])
    issues = checker.pre_update_issues

    context.fail!(issues: issues) if issues.any?
  end

  def update_file_attachment
    updater = Versioning::FileAttachmentRevisionUpdater.new(file_attachment_revision, user)
    attributes = attachment_params.slice(:title)
                                  .merge(blob_attributes(file_attachment_revision))

    updater.assign(attributes)
    context.file_attachment_revision = updater.next_revision
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_file_attachment(file_attachment_revision)

    context.fail!(unchanged: true) unless updater.changed?

    edition.assign_revision(updater.next_revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_updated,
                                      edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end

  def attachment_params
    params.require(:file_attachment).permit(:file, :title)
  end

  def blob_attributes(file_attachment_revision)
    return {} unless attachment_params[:file]

    FileAttachmentBlobAttributesService.new(file: attachment_params[:file],
                                            revision: edition.revision,
                                            replacement: file_attachment_revision)
                                       .call
  end
end
