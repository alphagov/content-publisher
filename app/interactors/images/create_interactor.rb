# frozen_string_literal: true

class Images::CreateInteractor
  include Interactor
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
  end

  def check_for_issues
    issues = Requirements::ImageUploadChecker.new(params[:image]).issues
    context.fail!(issues: issues) if issues.any?
  end

  def create_image_revision
    context.image_revision = ImageUploadService.new(params[:image], edition.revision)
                                               .call(user)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_image(image_revision, false)
    edition.assign_revision(updater.next_revision, user).save!
  end
end
