# frozen_string_literal: true

class Images::Create
  include Interactor
  delegate :params, :user, to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      check_issues(edition, params[:image])
      image_revision = upload_image(edition, params[:image])
      update_edition(edition, image_revision)
      update_context(edition: edition, image_revision: image_revision)
    end
  end

private

  def check_issues(edition, image_params)
    issues = Requirements::ImageUploadChecker.new(image_params).issues
    context.fail!(edition: edition, issues: issues) if issues.any?
  end

  def upload_image(edition, image_params)
    ImageUploadService.new(image_params, edition.revision).call(user)
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
