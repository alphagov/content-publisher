# frozen_string_literal: true

class Images::UpdateService < BusinessProcess::Base
  needs :params
  needs :user

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_update_image
      check_for_issues

      if @issues.any?
        return build_result
      end

      update_edition

      if @updater.changed?
        create_timeline_entry
        update_preview
      end

      build_result
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
    @issues = checker.pre_preview_metadata_issues
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

  def build_result
    { edition: @edition,
      image_revision: @image_revision,
      selected_lead_image: @updater&.selected_lead_image?,
      removed_lead_image: @updater&.removed_lead_image?,
      issues: @issues.any? && @issues }
  end
end
