# frozen_string_literal: true

require "beneractors/beneractor"

module Images
  class CreateActor < Beneractors::Beneractor
    def pre_op
      export :edition, Edition.find_current(document: document)
      edition.lock!

      export :issues, ::Requirements::ImageUploadChecker.new(image).issues
      abort!(:issues) if issues.any?
    end

    def op
      export :image_revision, ImageUploadService
        .new(image, edition.revision)
        .call(user)

      updater = Versioning::RevisionUpdater.new(edition.revision, user)
      updater.update_image(image_revision)

      edition.assign_revision(updater.next_revision, user)
      edition.save!
    end

    def post_op
      PreviewService.new(edition).try_create_preview
    end
  end
end
