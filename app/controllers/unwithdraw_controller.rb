# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def index
    @document = Document.find_by_param(params[:id])
  end
end
