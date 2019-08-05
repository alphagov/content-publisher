# frozen_string_literal: true

class VideoEmbedController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  def new
    if rendering_context != "modal"
      head :bad_request
    else
      render :new, layout: rendering_context
    end
  end

  def create
    result = VideoEmbed::CreateInteractor.call(params: params)
    issues, markdown_code = result.to_h.values_at(:issues, :markdown_code)

    if rendering_context != "modal"
      head :bad_request
    elsif issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { issues: issues },
             layout: rendering_context,
             status: :unprocessable_entity
    else
      render inline: markdown_code
    end
  end
end
