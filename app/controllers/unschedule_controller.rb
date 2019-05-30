# frozen_string_literal: true

class UnscheduleController < ApplicationController
  def unschedule
    result = Unschedule::UnscheduleInteractor.call(params: params, user: current_user)

    redirect_to document_path(params[:document])
  end
end
