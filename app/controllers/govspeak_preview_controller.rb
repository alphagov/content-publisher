# frozen_string_literal: true

class GovspeakPreviewController < ApplicationController
  skip_before_action :verify_authenticity_token

  def to_html
    @document = Document.with_current_edition.find_by_param(params[:id])
    current_edition = @document.current_edition
    render plain: GovspeakDocument.new(params[:govspeak], current_edition).in_app_html
  end
end
