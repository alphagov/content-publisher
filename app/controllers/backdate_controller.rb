# frozen_string_literal: true

class BackdateController < ApplicationController
  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
    assert_edition_state(@edition, &:first?)
  end

  def update
    result = Backdate::UpdateInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["requirements"] = {
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

  def destroy
    result = Backdate::DestroyInteractor.call(params: params, user: current_user)
    edition = result.edition
    redirect_to document_path(edition.document)
  end
end
