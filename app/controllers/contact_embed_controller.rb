# frozen_string_literal: true

class ContactEmbedController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "new_api_down", layout: rendering_context
  end

  def new
    @edition = Edition.find_current(document: params[:document])
    render layout: rendering_context
  end

  def create
    result = ContactEmbed::CreateInteractor.call(params: params)

    edition, markdown_code, issues = result.to_h.values_at(:edition,
                                                           :markdown_code,
                                                           :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { edition: edition, issues: issues },
             layout: rendering_context,
             status: :unprocessable_entity
    elsif rendering_context == "modal"
      render inline: markdown_code
    else
      render :new,
             assigns: { markdown_code: markdown_code, edition: edition },
             layout: rendering_context
    end
  end
end
