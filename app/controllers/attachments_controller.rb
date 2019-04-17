# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
  end

  def create
    redirect_to attachments_path(edition.document)
  end
end
