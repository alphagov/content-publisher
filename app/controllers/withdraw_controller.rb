# frozen_string_literal: true

class WithdrawController < ApplicationController
  def new
    @document = Document.with_current_edition.find_by_param(params[:id])
    edition = @document.current_edition
    @public_explanation =
      edition.withdrawn? ? edition.status.details.public_explanation : nil
  end

  def create
    Document.transaction do
      @document = Document.with_current_edition.lock!.find_by_param(params[:id])
      public_explanation = params[:public_explanation]
      issues = Requirements::WithdrawalChecker.new(public_explanation).pre_withdrawal_issues

      if issues.any?
        flash["alert_with_items"] = {
          "title" => I18n.t!("withdraw.new.flashes.requirements"),
          "items" => issues.items,
        }

        render :new
      else
        begin
          #FIXME We should check that the edition is withdrawable before passing
          # it to the UnpublishService
          UnpublishService.new.withdraw(@document.current_edition, public_explanation, current_user)
          redirect_to @document
        rescue GdsApi::BaseError => e
          GovukError.notify(e)
          redirect_to withdraw_path,
            alert_with_description: t("withdraw.new.flashes.publishing_api_error"),
            public_explanation: public_explanation
        end
      end
    end
  end
end
