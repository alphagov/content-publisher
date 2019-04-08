# frozen_string_literal: true

class Images::UpdateInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :issues,
           :selected_lead_image,
           :removed_lead_image,
           to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.transaction do
      context.edition = Edition.lock.find_current(document: params[:document])
      context.image_revision = update_image_revision(image_params)

      check_for_issues

      updater = update_image(params[:lead_image] == "on")

      context.selected_lead_image = updater.selected_lead_image?
      context.removed_lead_image = updater.removed_lead_image?

      if updater.changed?
        create_timeline_entry
        update_preview
      end
    end
  end

private

  def update_image_revision(update_params)
    image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    updater = Versioning::ImageRevisionUpdater.new(image_revision, user)
    updater.assign(update_params)
    updater.next_revision
  end

  def image_params
    params.require(:image_revision).permit(:caption, :alt_text, :credit)
  end

  def check_for_issues
    checker = Requirements::ImageRevisionChecker.new(image_revision)
    issues = checker.pre_preview_metadata_issues
    context.fail!(issues: issues) if issues.any?
  end

  def update_image(lead_image)
    Versioning::RevisionUpdater.new(edition.revision, user).tap do |updater|
      updater.update_image(image_revision, lead_image)
      edition.assign_revision(updater.next_revision, user).save! if updater.changed?
    end
  end

  def upload_image(image_params)
    upload_service = ImageUploadService.new(image_params, context.edition.revision)
    context.image_revision = upload_service.call(context.user)
  end

  def create_timeline_entry
    timeline_entry_type = if selected_lead_image
                            :lead_image_selected
                          elsif removed_lead_image
                            :lead_image_removed
                          else
                            :image_updated
                          end

    TimelineEntry.create_for_revision(entry_type: timeline_entry_type, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
