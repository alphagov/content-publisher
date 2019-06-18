# frozen_string_literal: true

class Backdate::UpdateInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :date,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(backdated_to: date)
    edition.assign_revision(updater.next_revision, user).save!
  end

  def backdate_params
    params.require(:backdate).permit(date: %i[day month year])
  end

  def check_for_issues
    unless edition.number == 1
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Only first editions can be backdated."
    end

    checker = Requirements::BackdateChecker.new(backdate_params[:date])
    issues = checker.pre_submit_issues

    context.fail!(issues: issues) if issues.any?

    context.date = checker.parsed_date
  end
end
