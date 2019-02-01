# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def index
    @document = Document.with_current_edition.find_by_param(params[:id])
  end
end
