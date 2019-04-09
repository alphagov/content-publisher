# frozen_string_literal: true

class Images::UpdateInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           :image_revision,
           :issues,
           :edition_updated,
           :selected_lead_image,
           :removed_lead_image,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_update_image

      check_for_issues
      update_edition

      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def find_and_update_image
    current_image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    image_params = params.require(:image_revision).permit(:caption, :alt_text, :credit)

    updater = Versioning::ImageRevisionUpdater.new(current_image_revision, user)
    updater.assign(image_params)

    context.image_revision = updater.next_revision
  end

  def check_for_issues
    checker = Requirements::ImageRevisionChecker.new(image_revision)
    issues = checker.pre_preview_metadata_issues

    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    is_lead_image = params[:lead_image] == "on"
    updater = Versioning::RevisionUpdater.new(edition.revision, user)

    updater.update_image(image_revision, is_lead_image)
    edition.assign_revision(updater.next_revision, user).save! if updater.changed?

    context.edition_updated = updater.changed?
    context.selected_lead_image = updater.selected_lead_image?
    context.removed_lead_image = updater.removed_lead_image?
  end

  def create_timeline_entry
    return unless edition_updated

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
    return unless edition_updated

    PreviewService.new(edition).try_create_preview
  end
end
