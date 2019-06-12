# frozen_string_literal: true

class Schedule::UpdateInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :revision,
           :issues,
           :publish_time,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      parse_publish_time
      update_revision
      check_for_issues
      update_edition
      reschedule_to_publish
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def parse_publish_time
    parser = DatetimeParser.new(**schedule_params)
    context.publish_time = parser.parse
    context.fail!(issues: parser.issues) if parser.issues.any?
  end

  def update_revision
    unless edition.scheduled?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't reschedule an edition which isn't scheduled"
    end

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(scheduled_publishing_datetime: publish_time)

    context.fail! unless updater.changed?
    context.revision = updater.next_revision
  end

  def check_for_issues
    checker = Requirements::ScheduleChecker.new(revision)
    issues = checker.pre_schedule_issues
    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    edition.assign_revision(revision, user).save!
  end

  def reschedule_to_publish
    ScheduleService.new(edition).reschedule(user: user)
  end

  def schedule_params
    params.require(:schedule).permit(:time, date: %i[day month year])
      .to_h.deep_symbolize_keys
  end
end
