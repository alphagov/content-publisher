# frozen_string_literal: true

class FileAttachments::CreateInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           :attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      upload_attachment
      update_edition
      update_preview
    end
  end

private

  def check_for_issues
    issues = Requirements::FileAttachmentUploadChecker.new(params[:file], params[:title]).issues
    context.fail!(issues: issues) if issues.any?
  end

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def upload_attachment
    context.attachment_revision = FileAttachmentUploadService.new(
      params[:file],
      edition.revision,
      params[:title],
    ).call(user)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.add_file_attachment(attachment_revision)
    edition.assign_revision(updater.next_revision, user).save!
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
