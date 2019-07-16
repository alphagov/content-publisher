# frozen_string_literal: true

class AccessLimitController < ApplicationController
  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    result = AccessLimit::UpdateInteractor.call(params: params, user: current_user)
    redirect_to document_path(result.edition.document)
  end
end
