# frozen_string_literal: true

class ScheduleController < ApplicationController
  def new
    @edition = Edition.find_current(document: params[:document])
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def create
    result = Schedule::CreateInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("schedule.new.flashes.requirements"),
        "items" => issues.items,
      }

      render :new,
             assigns: { issues: issues, edition: edition },
             status: :unprocessable_entity
    else
      redirect_to scheduled_path(edition.document)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document_path(params[:document]), alert_with_description: t("documents.show.flashes.schedule_error")
  end

  def destroy
    result = Schedule::DestroyInteractor.call(params: params, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.unschedule_error")
    else
      redirect_to document_path(params[:document])
    end
  end

  def scheduled
    @edition = Edition.find_current(document: params[:document])
  end
end
