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
      find_and_update_file_attachment

      update_edition
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def find_and_update_file_attachment
    current_attachment_revision = edition.file_attachment_revisions
                                         .find_by!(file_attachment_id: params[:file_attachment_id])
    attachment_params = params.require(:file_attachment).permit(:title)

    updater = Versioning::FileAttachmentRevisionUpdater.new(current_attachment_revision, user)
    updater.assign(attachment_params)

    context.file_attachment_revision = updater.next_revision
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_file_attachment(file_attachment_revision)

    context.fail! unless updater.changed?

    edition.assign_revision(updater.next_revision, user).save!
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
