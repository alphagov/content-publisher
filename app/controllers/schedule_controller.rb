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

      new_revision = edition.revision.build_revision_update(
        { scheduled_publishing_datetime: checker.parsed_datetime },
        current_user,
      )
      edition.assign_revision(new_revision, current_user).save!

      redirect_to document_path(document)
    end
  end

  def confirmation
    document = Document.with_current_edition.find_by_param(params[:id])
    @edition = document.current_edition
  end

  def schedule
    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      edition = document.current_edition
      reviewed = review_params == "reviewed"
      scheduling = Scheduling.new(pre_scheduled_status: edition.status, reviewed: reviewed)
      edition.assign_status(:scheduled, current_user, status_details: scheduling)
      edition.save!

      redirect_to document_path(document)
    end
  end

private

  def permitted_params
    params.require(:scheduled).permit(:year, :month, :day, :time)
  end

  def review_params
    params.require(:review_status)
  end
end
