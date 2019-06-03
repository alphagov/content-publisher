# frozen_string_literal: true

class TagsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    @revision = @edition.revision
  end

  def update
    results = Tags::UpdateInteractor.call(params: params, user: current_user)
    edition, revision, issues, = results.to_h.values_at(:edition, :revision, :issues)

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("documents.edit.flashes.requirements"),
        "items" => issues.items,
      }
      render :edit,
             assigns: { edition: edition, revision: revision },
             status: :unprocessable_entity
    else
      redirect_to document_path(params[:document])
    end
  end
end
