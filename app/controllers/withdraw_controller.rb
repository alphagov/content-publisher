# frozen_string_literal: true

class WithdrawController < ApplicationController
  def create
    @document = Document.find_by_param(params[:id])
  end

  def new
    document = Document.find_by_param(params[:id])
    public_explanation = params[:public_explanation]
    UnpublishService.new.retire(document, public_explanation)
    redirect_to document
  end
end
