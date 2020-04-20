class Requirements::Preview::ImagesChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def issues
    issues = Requirements::CheckerIssues.new

    edition.image_revisions.each do |image_revision|
      if image_revision.alt_text.blank?
        issues.create(:image_alt_text,
                      :blank,
                      filename: image_revision.filename,
                      image_revision: image_revision)
      end
    end

    issues
  end
end
