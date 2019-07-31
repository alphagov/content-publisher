# frozen_string_literal: true

class GovspeakPreviewController < ApplicationController
  skip_before_action :verify_authenticity_token

  def to_html
    edition = Edition.find_current(document: params[:document])
    govspeak_html = GovspeakDocument.new(params[:govspeak], edition).in_app_html
    render partial: "govuk_publishing_components/components/govspeak",
           locals: { content: govspeak_html.html_safe } # rubocop:disable Rails/OutputSafety
  end
end
