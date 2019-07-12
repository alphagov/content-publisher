# frozen_string_literal: true

class Images::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :issues,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      create_image_revision
      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def check_for_issues
    issues = Requirements::ImageUploadChecker.new(params[:image]).issues
    context.fail!(issues: issues) if issues.any?
  end

  def create_image_revision
    blob_revision = ImageBlobService.new(edition.revision, user)
                                    .create_blob_revision(params[:image])
    context.image_revision = Image::Revision.create_initial(blob_revision: blob_revision)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.add_image(image_revision)
    edition.assign_revision(updater.next_revision, user).save!
  end
end
