class VideoEmbedController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  layout "modal"

  before_action do
    raise ActionController::BadRequest unless rendering_context == "modal"
  end

  def create
    result = VideoEmbed::CreateInteractor.call(params: params)
    issues, markdown_code = result.to_h.values_at(:issues, :markdown_code)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { issues: issues },
             status: :unprocessable_entity
    else
      render plain: markdown_code
    end
  end
end
