# frozen_string_literal: true

class WithdrawController < ApplicationController
  def create
    @document = Document.find_by_param(params[:id])
  end
end
