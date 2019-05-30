# frozen_string_literal: true

RSpec.describe FileAttachmentBlobAttributesService do
  let(:file) { fixture_file_upload("files/text-file.txt") }
  let(:revision) { build(:revision) }

  describe "#call" do
    it "creates a blob and returns the id" do
      service = FileAttachmentBlobAttributesService.new(file: file, revision: revision)
      expect { service.call }
        .to change { ActiveStorage::Blob.count }
        .by(1)

      expect(service.call).to match(a_hash_including(blob_id: ActiveStorage::Blob.last.id))
    end

    it "returns the filename" do
      service = FileAttachmentBlobAttributesService.new(file: file, revision: revision)
      expect(service.call).to match(a_hash_including(filename: "text-file.txt"))
    end

    context "when the filename is used by an attachment for this revision" do
      let(:existing_attachment) { build(:file_attachment_revision, filename: "text-file.txt") }
      let(:revision) { build(:revision, file_attachment_revisions: [existing_attachment]) }

      it "updates the filename to be unique" do
        service = FileAttachmentBlobAttributesService.new(file: file, revision: revision)
        expect(service.call).to match(a_hash_including(filename: "text-file-1.txt"))
      end

      it "allows keeping the name if this is a replacement for the attachment with the same name" do
        service = FileAttachmentBlobAttributesService.new(file: file,
                                                          revision: revision,
                                                          replacement: existing_attachment)
        expect(service.call).to match(a_hash_including(filename: "text-file.txt"))
      end
    end

    context "when the upload is a pdf" do
      let(:file) { fixture_file_upload("files/13kb-1-page-attachment.pdf", "application/pdf") }

      it "returns the number of pages" do
        service = FileAttachmentBlobAttributesService.new(file: file, revision: revision)
        expect(service.call).to match(a_hash_including(number_of_pages: 1))
      end
    end

    context "when the upload is not a pdf" do
      it "returns nil for the number of pages" do
        service = FileAttachmentBlobAttributesService.new(file: file, revision: revision)
        expect(service.call).to match(a_hash_including(number_of_pages: nil))
      end
    end
  end
end
