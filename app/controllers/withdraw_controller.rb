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
    unless current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't withdraw an edition without managing editor permissions"
    end

    public_explanation = params[:public_explanation]

    Edition.find_and_lock_current(document: params[:document]) do |edition|
      issues = Requirements::WithdrawalChecker.new(public_explanation, edition)
                                              .pre_withdrawal_issues

      if issues.any?
        flash["alert_with_items"] = {
          "title" => I18n.t!("withdraw.new.flashes.requirements"),
          "items" => issues.items,
        }

        render :new, assigns: { edition: edition }, status: :unprocessable_entity
        next
      end

      #FIXME We should check that the edition is withdrawable before passing
      # it to the WithdrawService
      WithdrawService.new.call(edition, public_explanation, current_user)
      redirect_to document_path(edition.document)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to withdraw_path(params[:document]),
      alert_with_description: t("withdraw.new.flashes.publishing_api_error"),
      public_explanation: public_explanation
  end
end
