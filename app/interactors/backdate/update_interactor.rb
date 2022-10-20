class Backdate::UpdateInteractor < ApplicationInteractor
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
    assert_edition_state(edition, &:first?)
    assert_edition_state(edition, &:editable?)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(backdated_to: date)
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!

    context.fail! unless updater.changed?
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
    issues = Requirements::Form::BackdateChecker.call(date)
    context.fail!(issues:) if issues.any?
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(
      entry_type: :backdated,
      revision: edition.revision,
      edition:,
      created_by: user,
    )
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
