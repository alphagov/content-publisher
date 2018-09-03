# frozen_string_literal: true

class PreviewController < ApplicationController
  def show
    @document = Document.find_by_param(params[:id])
  end
end
