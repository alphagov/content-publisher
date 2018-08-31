# frozen_string_literal: true

class PreviewController < ApplicationController
  def show
    @document = Document.find(params[:id])
  end
end
