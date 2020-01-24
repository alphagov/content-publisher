# frozen_string_literal: true

class WithdrawController < ApplicationController
  before_action :check_permissions

  def new
    @edition = Edition.find_current(document: params[:document])
    @public_explanation = @edition.withdrawn? ? @edition.status.details.public_explanation : nil

    assert_edition_state(@edition, assertion: "is published or withdrawn") do
      @edition.published? || @edition.published_but_needs_2i? || @edition.withdrawn?
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
      flash.now["alert_with_description"] = t("withdraw.new.flashes.publishing_api_error")

      render :new,
             assigns: { edition: edition,
                        public_explanation: params[:public_explanation] },
             status: :service_unavailable
    else
      redirect_to document_path(edition.document)
    end
  end

private

  def check_permissions
    @edition = Edition.find_current(document: params[:document])

    if !current_user.has_permission?(User::MANAGE_LIVE_HISTORY_MODE) && @edition.history_mode?
      render "missing_permissions/update_history_mode", status: :forbidden
      return
    end

    if !current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      render :non_managing_editor, status: :forbidden
    end
  end
end
