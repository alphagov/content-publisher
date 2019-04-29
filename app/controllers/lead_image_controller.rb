# frozen_string_literal: true

class LeadImageController < ApplicationController
  def choose
    result = LeadImage::ChooseInteractor.call(params: params, user: current_user)
    image_revision = result.image_revision

    redirect_to document_path(params[:document]),
                notice: t("documents.show.flashes.lead_image.selected", file: image_revision.filename)
  end

  def remove
    result = LeadImage::RemoveInteractor.call(params: params, user: current_user)
    no_lead_image, image_revision = result.to_h.values_at(:no_lead_image, :image_revision)

    if no_lead_image
      redirect_to images_path(params[:document])
    else
      redirect_to images_path(params[:document]),
                  notice: t("images.index.flashes.lead_image.removed", file: image_revision.filename)
    end
  end
end
