# frozen_string_literal: true

class ContactEmbedController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "new_api_down", layout: rendering_context
  end

  def new
    render layout: rendering_context
  end

  def create
    if rendering_context == "modal"
      render inline: I18n.t!("contact_embed.new.contact_markdown",
                             id: params[:contact_id])
    else
      render "new", layout: rendering_context
    end
  end
end
