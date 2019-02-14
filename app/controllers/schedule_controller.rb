# frozen_string_literal: true

class ScheduleController < ApplicationController
  def save_scheduled_publishing_datetime
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:id])
      edition = document.current_edition

      new_revision = edition.revision.build_revision_update(
        { scheduled_publishing_datetime: format_datetime },
        current_user,
      )
      edition.assign_revision(new_revision, current_user).save!

      redirect_to document_path(document)
    end
  end

private

  def format_datetime
    Time.zone.parse(permitted_params.values.join("-"))
  end

  def permitted_params
    params.require(:scheduled).permit(:year, :month, :day, :time)
  end
end
