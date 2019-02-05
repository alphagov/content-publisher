# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def confirm
    document = Document.with_current_edition.find_by_param(params[:id])
    redirect_to document_path(document), confirmation: "unwithdraw/confirm"
  end

  def unwithdraw
    redirect_to document_path(params[:id])
  end
end
