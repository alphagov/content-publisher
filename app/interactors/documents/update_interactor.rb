# frozen_string_literal: true

class Documents::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_revision
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
    assert_edition_access(edition, user)
  end

  def update_revision
    update_params = params.require(:revision)

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(update_params.permit(:update_type, :change_note))

    content_params = update_params.require(:contents)
    content_fields = edition.document_type.contents
    content_fields.each { |field| field.update(content_params, updater) }

    context.fail! unless updater.changed?
    context.revision = updater.next_revision
  end

  def check_for_issues
    issues = Requirements::EditPageChecker.new(edition, revision).pre_preview_issues
    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    edition.assign_revision(revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
