RSpec.describe Requirements::Preview::ImagesChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      image_revision = build :image_revision, alt_text: "something"
      edition = build :edition, image_revisions: [image_revision]
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end

    it "returns an issue if an image has no alt text" do
      image_revision = build :image_revision
      edition = build :edition, image_revisions: [image_revision]
      issues = described_class.call(edition)

      expect(issues).to have_issue(:image_alt_text,
                                   :blank,
                                   styles: %i[summary],
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end
  end
end
