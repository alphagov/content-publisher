# frozen_string_literal: true

class GovspeakPreviewController < ApplicationController
  skip_before_action :verify_authenticity_token

  def to_html
    render plain: GovspeakService.new.to_html(params[:govspeak])
  end
end
