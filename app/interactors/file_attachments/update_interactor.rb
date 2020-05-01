class FileAttachments::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :file_attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_file_attachment
      check_for_issues

      update_file_attachment
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

  def find_file_attachment
    context.file_attachment_revision = edition.file_attachment_revisions
                                              .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def check_for_issues
    issues = Requirements::Form::FileAttachmentMetadataChecker.call(params.require(:file_attachment))
    context.fail!(issues: issues) if issues.any?
  end

  def update_file_attachment
    updater = Versioning::FileAttachmentRevisionUpdater.new(file_attachment_revision, user)
    updater.assign(attachment_params)
    context.file_attachment_revision = updater.next_revision
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_file_attachment(file_attachment_revision)

    context.fail!(unchanged: true) unless updater.changed?

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_updated,
                                      edition: edition)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def attachment_params
    raw_params = params.require(:file_attachment)

    { isbn: raw_params[:isbn],
      unique_reference: raw_params[:unique_reference],
      official_document_type: official_document_type(raw_params),
      paper_number: paper_number(raw_params) }
  end

  def paper_number(params)
    case params[:official_document_type]
    when "command_paper" then params[:command_paper_number]
    when "act_paper" then params[:act_paper_number]
    end
  end

  def official_document_type(params)
    case params[:official_document_type]
    when "command_paper", "unnumbered_command_paper" then "command_paper"
    when "act_paper", "unnumbered_act_paper" then "act_paper"
    when "unofficial" then "unofficial"
    end
  end
end
