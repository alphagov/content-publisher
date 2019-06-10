# frozen_string_literal: true

class ScheduleController < ApplicationController
  def new
    @edition = Edition.find_current(document: params[:document])

    unless @edition.schedulable?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Document is not in a schedulable state."
    end
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    result = Schedule::UpdateInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("schedule.edit.flashes.requirements"),
        "items" => issues.items(
          link_options: {
            schedule_date: { href: "#date" },
            schedule_time: { href: "#time" },
          },
        ),
      }

      render :edit,
             assigns: { edition: edition, issues: issues },
             status: :unprocessable_entity
    else
      redirect_to document_path(edition.document)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document_path(params[:document]), alert_with_description: t("documents.show.flashes.schedule_error")
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
