# frozen_string_literal: true

class Tags::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :revision,
           :revision_updater,
           :issues,
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
  end

  def update_revision
    context.revision_updater = Versioning::RevisionUpdater.new(edition.revision, user)
    revision_updater.assign(tags: update_params(edition))
    context.revision = revision_updater.next_revision
  end

  def check_for_issues
    checker = Requirements::TagChecker.new(edition, revision)
    issues = checker.pre_publish_issues

    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    context.fail! unless revision_updater.changed?
    edition.assign_revision(revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_tags, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end

  def update_params(edition)
    permits = edition.document_type.tags.map do |tag_field|
      [tag_field.id, []]
    end

    params.fetch(:tags, {}).permit(Hash[permits]).each { |_, v| v.reject!(&:empty?) }
  end
end
