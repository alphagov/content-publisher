# frozen_string_literal: true

class UnpublishController < ApplicationController
  def remove
    @edition = Edition.find_current(document: params[:document])
  end
end
