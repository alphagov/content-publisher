# frozen_string_literal: true

class WithdrawController < ApplicationController
  def new
    document = Document.with_current_edition.find_by_param(params[:id])
    @edition = document.current_edition
    @public_explanation =
      @edition.withdrawn? ? @edition.status.details.public_explanation : nil

    if !current_user.has_permission?(User::PRE_RELEASE_FEATURES_PERMISSION)
      render :withdraw
      return
    end

    if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      render :new
    else
      render :non_managing_editor, status: :forbidden
    end
  end

  def create
    unless user_has_permissions?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't withdraw an edition without permissions"
    end

    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      @edition = document.current_edition
      public_explanation = params[:public_explanation]
      issues = Requirements::WithdrawalChecker.new(public_explanation).pre_withdrawal_issues

      if issues.any?
        flash["alert_with_items"] = {
          "title" => I18n.t!("withdraw.new.flashes.requirements"),
          "items" => issues.items,
        }

        render :new
        return
      end

      begin
        #FIXME We should check that the edition is withdrawable before passing
        # it to the UnpublishService
        UnpublishService.new.withdraw(@edition, public_explanation, current_user)
        redirect_to @edition.document
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
        redirect_to withdraw_path,
          alert_with_description: t("withdraw.new.flashes.publishing_api_error"),
          public_explanation: public_explanation
      end
    end
  end

private

  def user_has_permissions?
    current_user.has_all_permissions?([User::MANAGING_EDITOR_PERMISSION,
                                       User::PRE_RELEASE_FEATURES_PERMISSION])
  end
end
