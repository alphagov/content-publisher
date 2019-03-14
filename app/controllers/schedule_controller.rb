# frozen_string_literal: true

class ScheduleController < ApplicationController
  def save_scheduled_publishing_datetime
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      checker = Requirements::ScheduledDatetimeChecker.new(permitted_params)
      issues = checker.pre_submit_issues

      if issues.any?
        href = { scheduled_datetime: "#scheduled_publishing_datetime" }
        flash["alert_with_items"] = {
          title: I18n.t!("requirements.scheduled_datetime.title"),
          items: issues.items(hrefs: href),
        }
        flash[:scheduled_publishing_params] = permitted_params
        redirect_to document_path(edition.document)
        next
      end

      set_scheduled_publishing_datetime(edition, checker.parsed_datetime)

      redirect_to document_path(edition.document)
    end
  end

  def clear_scheduled_publishing_datetime
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      set_scheduled_publishing_datetime(edition)

      redirect_to document_path(edition.document)
    end
  end

  def confirmation
    @edition = Edition.find_current(document: params[:document])

    unless @edition.schedulable?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Scheduled publishing date and time must be at least 15 minutes in the future."
    end
  end

  def schedule
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      if edition.scheduled_publishing_datetime.blank?
        # FIXME: this shouldn't be an exception but we've not worked out the
        # right response - maybe bad request or a redirect with flash?
        raise "Cannot schedule an edition to be published without setting a publishing date and time."
      end

      datetime = edition.scheduled_publishing_datetime
      ScheduledPublishingWorker.perform_at(datetime, edition.id)

      reviewed = review_params == "reviewed"
      ScheduleService.new(edition).schedule(user: current_user, reviewed: reviewed)

      redirect_to scheduled_path(edition.document)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    redirect_to document_path(params[:document]), alert_with_description: t("documents.show.flashes.schedule_error")
  end

  def scheduled
    @edition = Edition.find_current(document: params[:document])
  end

private

  def permitted_params
    params.require(:scheduled).permit(:year, :month, :day, :time)
  end

  def review_params
    params.require(:review_status)
  end

  def set_scheduled_publishing_datetime(edition, datetime = nil)
    current_revision = edition.revision
    new_revision = current_revision.build_revision_update(
      { scheduled_publishing_datetime: datetime }, current_user
    )
    if new_revision != current_revision
      edition.assign_revision(new_revision, current_user).save!
      create_timeline_entry(edition, new_revision, datetime)
    end
  end

  def create_timeline_entry(edition, revision, datetime)
    entry_type = if datetime
                   :scheduled_publishing_datetime_set
                 else
                   :scheduled_publishing_datetime_cleared
                 end
    TimelineEntry.create_for_revision(entry_type: entry_type,
                                      revision: revision,
                                      edition: edition,
                                      details: nil,
                                      created_by: current_user)
  end
end
