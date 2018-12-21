# frozen_string_literal: true

class WithdrawController < ApplicationController
  def new
    @document = Document.with_current_edition.find_by_param(params[:id])
  end
end
