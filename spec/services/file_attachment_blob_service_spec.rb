# frozen_string_literal: true

RSpec.describe FileAttachmentBlobService do
  let(:file) { fixture_file_upload("files/text-file.txt") }
  let(:revision) { build(:revision) }
  let(:user) { build(:user) }
  let(:instance) { FileAttachmentBlobService.new(revision, user) }

  describe "#create_blob_revision" do
    it "creates a file attachment blob revision" do
      expect(instance.create_blob_revision(file))
        .to be_a(FileAttachment::BlobRevision)
    end

    context "when the filename is used by an attachment for this revision" do
      let(:existing_attachment) { build(:file_attachment_revision, filename: "text-file.txt") }
      let(:revision) { build(:revision, file_attachment_revisions: [existing_attachment]) }

      it "creates a unique filename" do
        blob_revision = instance.create_blob_revision(file)
        expect(blob_revision.filename).to eql("text-file-1.txt")
      end

      it "allows keeping the name if this is a replacement for the attachment with the same name" do
        blob_revision = instance.create_blob_revision(file, replacing: existing_attachment)
        expect(blob_revision.filename).to eql("text-file.txt")
      end
    end

    context "when the upload is a pdf" do
      let(:file) { fixture_file_upload("files/13kb-1-page-attachment.pdf", "application/pdf") }

      it "calculates the number of pages" do
        blob_revision = instance.create_blob_revision(file)
        expect(blob_revision.number_of_pages).to eql(1)
      end
    end

    context "when the upload is not a pdf" do
      it "sets nil for the number of pages" do
        blob_revision = instance.create_blob_revision(file)
        expect(blob_revision.number_of_pages).to be_nil
      end
    end
  end
end
