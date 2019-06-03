# frozen_string_literal: true

class UnscheduleController < ApplicationController
  def unschedule
    result = Unschedule::UnscheduleInteractor.call(params: params, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.unschedule_error")
    else
      redirect_to document_path(params[:document])
    end
  end
end
