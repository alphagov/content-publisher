# frozen_string_literal: true

module Versioned
  class UnpublishController < BaseController
    def remove
      @document = Versioned::Document.with_current_edition.find_by_param(params[:id])
    end

    def retire
      @document = Versioned::Document.with_current_edition.find_by_param(params[:id])
    end
  end
end
