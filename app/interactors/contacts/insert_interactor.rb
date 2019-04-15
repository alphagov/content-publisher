# frozen_string_literal: true

class Contacts::InsertInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :empty_submission,
           :updated,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_submission

      update_edition

      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_for_submission
    context.fail!(empty_submission: true) if params[:contact_id].empty?
  end

  def update_edition
    contact_markdown = "[Contact:#{params[:contact_id]}]\n"
    revision = edition.revision

    body = revision.contents.fetch("body", "").chomp
    updated_body = if body.present?
                     "#{body}\n\n#{contact_markdown}"
                   else
                     contact_markdown
                   end

    updater = Versioning::RevisionUpdater.new(revision, user)
    updater.assign(contents: revision.contents.merge("body" => updated_body))

    edition.assign_revision(updater.next_revision, user).save! if updater.changed?
    context.updated = updater.changed?
  end

  def create_timeline_entry
    return unless updated

    TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
  end

  def update_preview
    return unless updated

    PreviewService.new(edition).try_create_preview
  end
end

