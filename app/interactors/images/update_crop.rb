# frozen_string_literal: true

class Images::UpdateCrop
  include Interactor
  delegate :params, :user, to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])

      updater = Versioning::ImageRevisionUpdater.new(image_revision, user)
      updater.assign(crop_params)

      if updater.changed?
        update_edition(edition, updater.next_revision)
        TimelineEntry.create_for_revision(entry_type: :image_updated,
                                          edition: edition)
        PreviewService.new(edition).try_create_preview
      end

      update_context(edition: edition, image_revision: updater.next_revision)
    end
  end

private

  def crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH
    crop_height = params[:crop_width].to_i * image_aspect_ratio
    # FIXME: this will raise a warning because of unpermitted paramaters
    params.permit(:crop_x, :crop_y, :crop_width)
          .merge(crop_height: crop_height.round)
  end

  def update_edition(edition, image_revision)
    updater = Versioning::RevisionUpdater.new(edition.revision, user)

    updater.update_image(image_revision, false)
    edition.assign_revision(updater.next_revision, user).save!
  end

  def update_context(attributes)
    attributes.each { |k, v| context[k.to_sym] = v }
  end
end
