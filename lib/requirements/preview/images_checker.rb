class Requirements::Preview::ImagesChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def check
    edition.image_revisions.each do |image_revision|
      next if image_revision.alt_text.present?

      issues.create(:image_alt_text,
                    :blank,
                    filename: image_revision.filename,
                    image_revision: image_revision)
    end
  end
end
