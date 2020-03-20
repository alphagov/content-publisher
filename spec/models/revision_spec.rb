RSpec.describe Revision do
  describe "#featured_attachments" do
    it "returns all attachments for the revision" do
      file_attachment = build(:file_attachment_revision)
      revision = build(:revision, file_attachment_revisions: [file_attachment])
      expect(revision.featured_attachments).to eq [file_attachment]
    end

    it "copes if some attachments are not ordered" do
      file_attachment1 = create(:file_attachment_revision)
      file_attachment2 = create(:file_attachment_revision)
      attachments = [file_attachment1, file_attachment2]
      ordering = [file_attachment1.featured_attachment_id]

      revision = build(:revision,
                       file_attachment_revisions: attachments,
                       featured_attachment_ordering: ordering)

      expect(revision.featured_attachments).to eq attachments
    end

    it "returns attachments in featured order" do
      file_attachment1 = create(:file_attachment_revision)
      file_attachment2 = create(:file_attachment_revision)
      attachments = [file_attachment1, file_attachment2]
      ordering = attachments.map(&:featured_attachment_id).reverse

      revision = build(:revision,
                       file_attachment_revisions: attachments,
                       featured_attachment_ordering: ordering)

      expect(revision.featured_attachments).to eq attachments.reverse
    end
  end
end
