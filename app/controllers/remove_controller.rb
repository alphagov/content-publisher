# frozen_string_literal: true

class RemoveController < ApplicationController
  def remove
    @edition = Edition.find_current(document: params[:document])
  end
end
