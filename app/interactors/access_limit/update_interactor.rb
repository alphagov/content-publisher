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
      update_preview
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
      EditDraftEditionService.call(edition, user, access_limit: nil)
      return
    end

    context.fail! if edition.access_limit&.limit_type == limit_type

    access_limit = AccessLimit.new(created_by: user,
                                   edition:,
                                   limit_type:,
                                   revision_at_creation: edition.revision)

    EditDraftEditionService.call(edition, user, access_limit:)
  end

  def check_for_issues
    issues = Requirements::Form::AccessLimitChecker.call(edition, user)
    context.fail!(issues:) if issues.any?
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
      entry_type:,
      created_by: user,
      edition:,
      details: edition.access_limit,
    )
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
