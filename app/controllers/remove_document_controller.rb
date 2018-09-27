# frozen_string_literal: true

class RemoveDocumentController < ApplicationController
  def remove
    @document = Document.find_by_param(params[:id])
  end
end
