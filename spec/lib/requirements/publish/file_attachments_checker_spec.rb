RSpec.describe Requirements::Publish::FileAttachmentsChecker do
  describe ".call" do
    let(:document_type) { build :document_type, attachments: "featured" }

    it "returns no issues if there are none" do
      attachment_revision = build(:file_attachment_revision, official_document_type: "unofficial")
      edition = build :edition, document_type: document_type, file_attachment_revisions: [attachment_revision]
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end

    it "returns an issue when the official document type is blank" do
      attachment_revision = build(:file_attachment_revision)
      edition = build :edition, document_type: document_type, file_attachment_revisions: [attachment_revision]
      issues = described_class.call(edition)

      expect(issues).to have_issue(:file_attachment_official_document_type,
                                   :blank,
                                   styles: %i[summary],
                                   filename: attachment_revision.filename,
                                   attachment_revision: attachment_revision)
    end

    it "returns no issues unless the document type supports featured attachments" do
      attachment_revision = build(:file_attachment_revision)
      edition = build :edition, file_attachment_revisions: [attachment_revision]
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end
  end
end
