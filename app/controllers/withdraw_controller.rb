# frozen_string_literal: true

class WithdrawController < ApplicationController
  def new
    @document = Document.with_current_edition.find_by_param(params[:id])
  end

  def create
    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      public_explanation = params[:public_explanation]

      #FIXME We should check that the edition is withdrawable before passing
      # it to the UnpublishService
      UnpublishService.new.withdraw(document.current_edition, public_explanation)
      redirect_to document
    end
  end
end
