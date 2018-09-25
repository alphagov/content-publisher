# frozen_string_literal: true

class RetireDocumentController < ApplicationController
  def retire
    @document = Document.find_by_param(params[:id])
  end
end
