# frozen_string_literal: true

class FileAttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
  end

  def show
    @edition = Edition.find_current(document: params[:document])

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def create
    result = FileAttachments::CreateInteractor.call(params: params, user: current_user)
    edition, attachment_revision = result.to_h.values_at(:edition, :attachment_revision)
    redirect_to file_attachment_path(edition.document, attachment_revision.file_attachment)
  end
end
