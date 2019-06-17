# frozen_string_literal: true

class Backdate::UpdateInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(backdated_to: submitted_date)
    edition.assign_revision(updater.next_revision, user).save!
  end

  def backdate_params
    params.require(:backdate).permit(:day, :month, :year)
  end

  def submitted_date
    Time.zone.local(backdate_params[:year].to_i,
                    backdate_params[:month].to_i,
                    backdate_params[:day].to_i)
  end
end
