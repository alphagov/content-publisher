# frozen_string_literal: true

class FileAttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
  end

  def create
    result = FileAttachments::CreateInteractor.call(params: params, user: current_user)
    edition = result.edition
    redirect_to file_attachments_path(edition.document)
  end
end
