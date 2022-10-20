class Images::UpdateCropInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_update_image
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

  def find_and_update_image
    current_image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    updater = Versioning::ImageRevisionUpdater.new(current_image_revision, user)
    updater.assign(crop_params)
    context.image_revision = updater.next_revision
  end

  def crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH

    params
      .require(:image_revision)
      .permit(:crop_x, :crop_y, :crop_width, :crop_width)
      .tap { |p| p[:crop_height] = (p[:crop_width].to_i * image_aspect_ratio).round }
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_image(image_revision)
    context.fail! unless updater.changed?
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :image_updated, edition:)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
