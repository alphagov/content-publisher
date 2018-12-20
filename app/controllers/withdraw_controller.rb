# frozen_string_literal: true

class WithdrawController < ApplicationController
  def create
    @document = Document.find_by_param(params[:id])
    @public_explanation = @document.retirement&.explanatory_note || params[:public_explanation]
    if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      render :create
    else
      render :non_managing_editor
    end
  end

  def new
    @document = Document.find_by_param(params[:id])
    public_explanation = params[:public_explanation]
    issues = Requirements::PublicExplanationChecker.new(public_explanation).pre_withdrawal_issues
    if issues.any?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("withdraw_document.withdraw.flashes.requirements"),
        "items" => issues.items,
      }

      render :create, public_explanation: public_explanation
      return
    end

    UnpublishService.new.retire(@document, public_explanation)
    redirect_to @document
  end
end
