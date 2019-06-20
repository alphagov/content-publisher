# frozen_string_literal: true

class BackdateController < ApplicationController
  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    result = Backdate::UpdateInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("backdate.edit.flashes.requirements"),
        "items" => issues.items(
          link_options: { backdate_date: { href: "#backdate-date" } },
        ),
      }

      render :edit,
             assigns: { edition: edition, issues: issues },
             status: :unprocessable_entity
    else
      redirect_to document_path(edition.document)
    end
  end
end
