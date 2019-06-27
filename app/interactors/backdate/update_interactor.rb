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

      parse_date
      check_for_issues

      update_edition
      create_timeline_entry

      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])

    unless edition.first? && edition.editable?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Only editable first editions can be backdated."
    end
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(backdated_to: date)
    context.fail! unless updater.changed?

    edition.assign_revision(updater.next_revision, user).save!
  end

  def backdate_params
    params.require(:backdate).permit(date: %i[day month year])
  end

  def parse_date
    parser = DateParser.new(date: backdate_params[:date], issue_prefix: :backdate)
    context.date = parser.parse

    context.fail!(issues: parser.issues) if parser.issues.any?
  end

  def check_for_issues
    checker = Requirements::BackdateChecker.new(date)
    issues = checker.pre_submit_issues

    context.fail!(issues: issues) if issues.any?
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(
      entry_type: :backdated,
      revision: edition.revision,
      edition: edition,
      created_by: user,
    )
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
