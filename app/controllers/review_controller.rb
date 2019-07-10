# frozen_string_literal: true

class ReviewController < ApplicationController
  def submit_for_2i
    result = Review::SubmitFor2iInteractor.call(params: params, user: current_user)
    issues, api_error = result.to_h.values_at(:issues, :api_error)

    if api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.2i_error")
    elsif issues
      redirect_to document_path(params[:document]), tried_to_publish: true
    else
      flash[:submitted_for_review] = true
      redirect_to document_path(params[:document])
    end
  end

  def approve
    Review::ApproveInteractor.call(params: params, user: current_user)

    redirect_to document_path(params[:document]),
                notice: t("documents.show.flashes.approved")
  end
end
