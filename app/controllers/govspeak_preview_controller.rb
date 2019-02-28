# frozen_string_literal: true

class GovspeakPreviewController < ApplicationController
  skip_before_action :verify_authenticity_token

  def to_html
    @document = Document.with_current_edition.find_by_param(params[:id])
    current_edition = @document.current_edition
    govspeak_html = GovspeakDocument.new(params[:govspeak], current_edition).in_app_html
    render partial: "govuk_publishing_components/components/govspeak",
           locals: { content: govspeak_html.html_safe } # rubocop:disable Rails/OutputSafety
  end
end
