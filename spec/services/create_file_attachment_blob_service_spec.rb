RSpec.describe CreateFileAttachmentBlobService do
  let(:file) { fixture_file_upload("files/text-file-74bytes.txt") }
  let(:revision) { build(:revision) }
  let(:user) { build(:user) }

  describe ".call" do
    it "creates a file attachment blob revision" do
      expect(CreateFileAttachmentBlobService.call(file: file, filename: "file.txt"))
        .to be_a(FileAttachment::BlobRevision)
    end

    context "when the upload is a pdf" do
      let(:file) { fixture_file_upload("files/13kb-1-page-attachment.pdf", "application/pdf") }

      it "calculates the number of pages" do
        blob_revision = CreateFileAttachmentBlobService.call(file: file, filename: "file.txt")
        expect(blob_revision.number_of_pages).to be(1)
      end
    end

    context "when the upload is not a pdf" do
      it "sets nil for the number of pages" do
        blob_revision = CreateFileAttachmentBlobService.call(file: file, filename: "file.txt")
        expect(blob_revision.number_of_pages).to be_nil
      end
    end
  end
end
