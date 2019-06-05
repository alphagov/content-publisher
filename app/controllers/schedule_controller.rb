# frozen_string_literal: true

class ScheduleController < ApplicationController
  def save_datetime
    result = Schedule::SaveDatetimeInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("schedule.scheduled_publishing_datetime.flashes.requirements"),
        "items" => issues.items(
          link_options: {
            scheduled_datetime: { href: "#scheduled_publishing_datetime" },
          },
        ),
      }

      render :scheduled_publishing_datetime,
             assigns: { edition: edition, issues: issues },
             status: :unprocessable_entity
    elsif params[:schedule][:action] == "schedule"
      redirect_to scheduling_confirmation_path(edition.document)
    else
      redirect_to document_path(edition.document)
    end
  end

  def clear_scheduled_publishing_datetime
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.assign(scheduled_publishing_datetime: nil)

      if updater.changed?
        edition.assign_revision(updater.next_revision, current_user).save!
        create_datetime_cleared_timeline_entry(edition)
      end

      redirect_to document_path(edition.document)
    end
  end

  def confirmation
    @edition = Edition.find_current(document: params[:document])

    unless @edition.schedulable?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Document is not in a schedulable state."
    end
  end

  def schedule
    result = Schedule::ScheduleInteractor.call(params: params, user: current_user)
    edition, issues = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("schedule.scheduled_publishing_datetime.flashes.requirements"),
        "items" => issues.items,
      }

      render :confirmation,
             assigns: { issues: issues, edition: edition },
             status: :unprocessable_entity
    else
      redirect_to scheduled_path(edition.document)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document_path(params[:document]), alert_with_description: t("documents.show.flashes.schedule_error")
  end

  def scheduled
    @edition = Edition.find_current(document: params[:document])
  end

  def scheduled_publishing_datetime
    @edition = Edition.find_current(document: params[:document])
  end

private

  def create_datetime_cleared_timeline_entry(edition)
    TimelineEntry.create_for_revision(entry_type: :scheduled_publishing_datetime_cleared, edition: edition)
  end
end
