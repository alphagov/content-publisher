# frozen_string_literal: true

class Images::UpdateInteractor
  include Interactor

  delegate :params, :user, to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_update_image
      check_for_issues
      update_edition

      if @updater.changed?
        create_timeline_entry
        update_preview
      end

      update_context
    end
  end

private

  def find_and_lock_edition
    @edition = Edition.lock.find_current(document: params[:document])
  end

  def find_and_update_image
    image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    image_params = params.require(:image_revision).permit(:caption, :alt_text, :credit)

    updater = Versioning::ImageRevisionUpdater.new(image_revision, user)
    updater.assign(image_params)
    @image_revision = updater.next_revision
  end

  def check_for_issues
    checker = Requirements::ImageRevisionChecker.new(@image_revision)
    issues = checker.pre_preview_metadata_issues
    return unless issues.any?

    context.fail!(issues: issues,
                  edition: @edition,
                  image_revision: @image_revision)
  end

  def update_edition
    is_lead_image = params[:lead_image] == "on"
    @updater = Versioning::RevisionUpdater.new(@edition.revision, user)

    @updater.update_image(@image_revision, is_lead_image)
    @edition.assign_revision(@updater.next_revision, user).save! if @updater.changed?
  end

  def create_timeline_entry
    timeline_entry_type = if @updater.selected_lead_image?
                            :lead_image_selected
                          elsif @updater.removed_lead_image?
                            :lead_image_removed
                          else
                            :image_updated
                          end

    TimelineEntry.create_for_revision(entry_type: timeline_entry_type, edition: @edition)
  end

  def update_preview
    PreviewService.new(@edition).try_create_preview
  end

  def update_context
    context.edition = @edition
    context.image_revision = @image_revision
    context.selected_lead_image = @updater.selected_lead_image?
    context.removed_lead_image = @updater.removed_lead_image?
  end
end
