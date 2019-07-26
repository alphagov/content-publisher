# frozen_string_literal: true

class AccessLimitController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    result = AccessLimit::UpdateInteractor.call(params: params, user: current_user)
    issues, edition = result.to_h.values_at(:issues, :edition)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :edit,
             assigns: { edition: edition, issues: issues },
             status: :unprocessable_entity
    else
      redirect_to document_path(edition.document)
    end
  end
end
