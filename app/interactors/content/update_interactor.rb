# frozen_string_literal: true

class Content::UpdateInteractor < ApplicationInteractor
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
  end

  def update_revision
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(content_params)
    updater.assign(change_note_params)
    context.fail! unless updater.changed?
    context.revision = updater.next_revision
  end

  def check_for_issues
    issues = Requirements::CheckerIssues.new

    fields = [
      DocumentType::TitleAndBasePathField.new,
      DocumentType::SummaryField.new,
    ] + edition.document_type.contents

    fields.each do |field|
      issues += field.pre_update_issues(edition, revision)
    end

    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    EditDraftEditionService.call(edition, user, revision: revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :updated_content, edition: edition)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def change_note_params
    params.require(:revision).permit(:update_type, :change_note)
  end

  def content_params
    fields = [
      DocumentType::TitleAndBasePathField.new,
      DocumentType::SummaryField.new,
    ] + edition.document_type.contents

    fields.each_with_object({}) do |field, hash|
      hash.merge!(field.updater_params(edition, params))
    end
  end
end
