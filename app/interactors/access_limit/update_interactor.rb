# frozen_string_literal: true

class AccessLimit::UpdateInteractor < ApplicationInteractor
  LIMIT_TYPES = AccessLimit.limit_types.keys

  delegate :params,
           :user,
           :edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_access_limit
      check_for_issues
      update_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def update_access_limit
    limit_type = params.require(:limit_type)

    if LIMIT_TYPES.exclude?(limit_type)
      context.fail! if edition.access_limit.nil?
      edition.assign_as_edit(user, access_limit: nil)
      return
    end

    context.fail! if edition.access_limit&.limit_type == limit_type

    access_limit = AccessLimit.new(created_by: user,
                                   edition: edition,
                                   limit_type: limit_type,
                                   revision_at_creation: edition.revision)

    edition.assign_as_edit(user, access_limit: access_limit)
  end

  def check_for_issues
    issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    edition.save!
  end

  def create_timeline_entry
    entry_type = if edition.access_limit.nil?
                   :access_limit_removed
                 elsif edition.access_limit_id_before_last_save.nil?
                   :access_limit_created
                 else
                   :access_limit_updated
                 end

    TimelineEntry.create_for_edition(
      entry_type: entry_type,
      created_by: user,
      edition: edition,
      details: edition.access_limit,
    )
  end
end
