# frozen_string_literal: true

class AccessLimit::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def update_edition
    context.fail! if edition.access_limit&.limit_type == params[:limit_type]
    edition.assign_access_limit(params[:limit_type], user).save!
  end

  def create_timeline_entry
    entry_type = if edition.access_limit_id_before_last_save.nil?
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
