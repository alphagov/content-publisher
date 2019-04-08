# frozen_string_literal: true

class Images::UpdateCropInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.transaction do
      context.edition = Edition.lock.find_current(document: params[:document])

      updater = update_image(find_image_revision(params[:image_id]), crop_params)

      if updater.changed?
        create_timeline_entry
        update_preview
      end

      context.image_revision = updater.next_revision
    end
  end

private

  def find_image_revision(image_id)
    edition.image_revisions.find_by!(image_id: image_id)
  end

  def crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH

    params
      .require(:image_revision)
      .permit(:crop_x, :crop_y, :crop_width, :crop_width)
      .tap { |p| p[:crop_height] = (p[:crop_width].to_i * image_aspect_ratio).round }
  end

  def update_image(image_revision, params)
    Versioning::ImageRevisionUpdater.new(image_revision, user).tap do |updater|
      updater.assign(params)
      update_edition(updater.next_revision) if updater.changed?
    end
  end

  def update_edition(image_revision)
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_image(image_revision, false)
    edition.assign_revision(updater.next_revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :image_updated, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
