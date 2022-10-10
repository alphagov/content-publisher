class ContactEmbedController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "new_api_down", status: :service_unavailable
  end

  def new
    @edition = Edition.find_current(document: params[:document])
  end

  def create
    result = ContactEmbed::CreateInteractor.call(params:)

    edition, markdown_code, issues = result.to_h.values_at(:edition,
                                                           :markdown_code,
                                                           :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { edition:, issues: },
             status: :unprocessable_entity
    elsif rendering_context == "modal"
      render plain: markdown_code
    else
      render :new, assigns: { markdown_code:, edition: }
    end
  end
end
