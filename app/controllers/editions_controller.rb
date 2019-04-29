# frozen_string_literal: true

class EditionsController < ApplicationController
  def create
    result = Editions::CreateInteractor.call(params: params, user: current_user)
    if result.draft_current_edition
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't create a new edition when the current edition is a draft"
    else
      redirect_to edit_document_path(params[:document])
    end
  end
end
