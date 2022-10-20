class Images::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :issues,
           :selected_lead_image,
           :removed_lead_image,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_image
      check_for_issues

      update_image
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

  def find_image
    context.image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
  end

  def check_for_issues
    issues = Requirements::Form::ImageMetadataChecker.call(image_params)
    context.fail!(issues:) if issues.any?
  end

  def update_image
    updater = Versioning::ImageRevisionUpdater.new(image_revision, user)
    updater.assign(image_params)
    context.image_revision = updater.next_revision
  end

  def update_edition
    is_lead_image = params[:lead_image] == "on"
    raise ActionController::BadRequest if !edition.document_type.lead_image? && is_lead_image

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_image(image_revision)
    updater.assign_lead_image(image_revision, is_lead_image)

    context.fail! unless updater.changed?

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!

    context.selected_lead_image = updater.selected_lead_image?
    context.removed_lead_image = updater.removed_lead_image?
  end

  def create_timeline_entry
    timeline_entry_type = if selected_lead_image
                            :lead_image_selected
                          elsif removed_lead_image
                            :lead_image_removed
                          else
                            :image_updated
                          end

    TimelineEntry.create_for_revision(entry_type: timeline_entry_type, edition:)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def image_params
    params.require(:image_revision).permit(:caption, :alt_text, :credit)
  end
end
