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
    result = ContactEmbed::CreateInteractor.call(params: params)
    markdown_code, issues = result.to_h.values_at(:markdown_code, :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { issues: issues },
             layout: rendering_context,
             status: :unprocessable_entity
    elsif rendering_context == "modal"
      render inline: markdown_code
    else
      render "new", layout: rendering_context
    end
  end
end
