# frozen_string_literal: true

class UnpublishController < ApplicationController
  def remove
    @document = Document.find_by_param(params[:id])
  end

  def retire
    @document = Document.find_by_param(params[:id])
  end
end
