# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
  end

  def create
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      attachment_revision = FileAttachmentUploadService.new(
        params[:file],
        edition.revision,
        params[:title],
      ).call(current_user)

      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.update_file_attachment(attachment_revision)

      edition.assign_revision(updater.next_revision, current_user).save!

      redirect_to attachments_path(edition.document)
    end
  end
end
