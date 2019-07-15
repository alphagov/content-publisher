# frozen_string_literal: true

class ScheduleProposalController < ApplicationController
  def update
    result = ScheduleProposal::UpdateInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(
          link_options: {
            schedule_date: { href: "#date" },
            schedule_time: { href: "#time" },
            schedule_action: { href: "#action" },
          },
        ),
      }

      render :edit,
             assigns: { edition: edition, issues: issues },
             status: :unprocessable_entity
    elsif params.dig(:schedule, :action) == "schedule"
      redirect_to new_schedule_path(edition.document, wizard: params[:wizard])
    else
      redirect_to document_path(edition.document)
    end
  end

  def destroy
    result = ScheduleProposal::DestroyInteractor.call(params: params, user: current_user)
    edition = result.edition
    redirect_to document_path(edition.document)
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
  end
end
