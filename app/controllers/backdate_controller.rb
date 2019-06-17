# frozen_string_literal: true

class BackdateController < ApplicationController
  def edit
    @edition = Edition.find_current(document: params[:document])
  end

  def update
    @edition = Edition.find_current(document: params[:document])
    update_backdated_to(@edition)

    redirect_to document_path(@edition.document)
  end

private

  def permitted_params
    params.require(:backdate).permit(:day, :month, :year)
  end

  def submitted_date
    Time.zone.local(permitted_params[:year].to_i,
                    permitted_params[:month].to_i,
                    permitted_params[:day].to_i)
  end

  def update_backdated_to(edition)
    updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
    updater.assign(backdated_to: submitted_date)
    edition.assign_revision(updater.next_revision, current_user).save!
  end
end
