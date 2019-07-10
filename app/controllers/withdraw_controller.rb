# frozen_string_literal: true

class WithdrawController < ApplicationController
  def new
    @edition = Edition.find_current(document: params[:document])
    @public_explanation =
      @edition.withdrawn? ? @edition.status.details.public_explanation : nil

    if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      render :new
    else
      render :non_managing_editor, status: :forbidden
    end
  end

  def create
    result = Withdraw::CreateInteractor.call(params: params, user: current_user)
    edition, issues, api_error = result.to_h.values_at(:edition, :issues, :api_error)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { edition: edition,
                        public_explanation: params[:public_explanation],
                        issues: issues },
             status: :unprocessable_entity
    elsif api_error
      redirect_to withdraw_path(params[:document]),
                  alert_with_description: t("withdraw.new.flashes.publishing_api_error"),
                  public_explanation: params[:public_explanation]
    else
      redirect_to document_path(edition.document)
    end
  end
end
