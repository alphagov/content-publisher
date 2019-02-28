# frozen_string_literal: true

class ScheduleController < ApplicationController
  def save_scheduled_publishing_datetime
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])
      edition = document.current_edition

      checker = Requirements::ScheduledDatetimeChecker.new(permitted_params)
      issues = checker.pre_submit_issues

      if issues.any?
        flash[:scheduled_publishing_datetime_issues] = issues.items_for(:scheduled_datetime)
        flash[:scheduled_publishing_params] = permitted_params
        redirect_to document_path(document)
        return
      end

      set_scheduled_publishing_datetime(edition, checker.parsed_datetime)

      redirect_to document_path(document)
    end
  end

  def clear_scheduled_publishing_datetime
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])
      edition = document.current_edition

      set_scheduled_publishing_datetime(edition)

      redirect_to document_path(document)
    end
  end

  def confirmation
    document = Document.with_current_edition.find_by_param(params[:id])
    @edition = document.current_edition

    unless @edition.schedulable?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Scheduled publishing date and time must be at least 15 minutes in the future."
    end
  end

  def schedule
    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      edition = document.current_edition

      if edition.scheduled_publishing_datetime.blank?
        # FIXME: this shouldn't be an exception but we've not worked out the
        # right response - maybe bad request or a redirect with flash?
        raise "Cannot schedule an edition to be published without setting a publishing date and time."
      end

      reviewed = review_params == "reviewed"
      ScheduleService.new(edition).schedule(user: current_user, reviewed: reviewed)

      redirect_to scheduled_path(document)
    end
  end

  def scheduled
    document = Document.with_current_edition.find_by_param(params[:id])
    @edition = document.current_edition
  end

private

  def permitted_params
    params.require(:scheduled).permit(:year, :month, :day, :time)
  end

  def review_params
    params.require(:review_status)
  end

  def set_scheduled_publishing_datetime(edition, datetime = nil)
    new_revision = edition.revision.build_revision_update(
      { scheduled_publishing_datetime: datetime }, current_user
    )
    edition.assign_revision(new_revision, current_user).save!
  end
end
