# frozen_string_literal: true

RSpec.describe FileAttachmentBlobService do
  let(:file) { fixture_file_upload("files/text-file.txt") }
  let(:revision) do
    build(:revision, file_attachment_revisions: [file_attachment_revision])
  end
  let(:file_attachment_revision) do
    build(:file_attachment_revision, filename: "text-file.txt")
  end

  describe "#blob_id" do
    it "returns the id for the newly created blob" do
      service = FileAttachmentBlobService.new(file: file, revision: revision)
      expect(service.blob_id).to be(ActiveStorage::Blob.last.id)
    end
  end

  describe "#filename" do
    context "the file is a replacement for an existing file attachment file" do
      it "returns the file's filename" do
        service = FileAttachmentBlobService.new(
          file: file,
          revision: revision,
          replacement: file_attachment_revision,
        )
        expect(service.filename).to eq(file.original_filename)
      end
    end

    context "the file is not a replacement for an existing file attachment file" do
      it "returns a unique filename if the file has existing file attachments" do
        service = FileAttachmentBlobService.new(file: file, revision: revision)
        expect(service.filename).to eq("text-file-1.txt")
      end
    end
  end

  describe "#number_of_pages" do
    it "returns the number of pages for a PDF" do
      pdf = fixture_file_upload("files/13kb-1-page-attachment.pdf", "application/pdf")
      service = FileAttachmentBlobService.new(file: pdf, revision: revision)
      expect(service.number_of_pages).to eq(1)
    end

    it "returns nil if the file is not a PDF" do
      service = FileAttachmentBlobService.new(file: file, revision: revision)
      expect(service.number_of_pages).to be nil
    end
  end
end
