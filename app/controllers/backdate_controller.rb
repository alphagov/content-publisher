# frozen_string_literal: true

class BackdateController < ApplicationController
  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    result = Backdate::UpdateInteractor.call(params: params, user: current_user)
    edition = result[:edition]

    redirect_to document_path(edition.document)
  end
end
