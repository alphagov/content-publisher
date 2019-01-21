# frozen_string_literal: true

class UnpublishController < ApplicationController
  def remove
    @document = Document.with_current_edition.find_by_param(params[:id])
  end

  def withdraw
    @document = Document.with_current_edition.find_by_param(params[:id])
  end
end
