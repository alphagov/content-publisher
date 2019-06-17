# frozen_string_literal: true

class BackdateController < ApplicationController
  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    @edition = Edition.find_current(document: params[:document])
    redirect_to document_path(@edition.document)
  end
end
