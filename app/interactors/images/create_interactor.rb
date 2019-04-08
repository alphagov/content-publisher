# frozen_string_literal: true

class Images::CreateInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :issues,
           to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.transaction do
      context.edition = Edition.lock.find_current(document: params[:document])
      check_for_issues(params[:image])

      context.image_revision = upload_image(params[:image])
      update_edition
    end
  end

private

  def check_for_issues(image_params)
    issues = Requirements::ImageUploadChecker.new(image_params).issues
    context.fail!(issues: issues) if issues.any?
  end

  def upload_image(image_params)
    ImageUploadService.new(image_params, edition.revision).call(user)
  end

  def update_edition
    Versioning::RevisionUpdater.new(edition.revision, user).tap do |updater|
      updater.update_image(image_revision, false)
      edition.assign_revision(updater.next_revision, user).save!
    end
  end
end
