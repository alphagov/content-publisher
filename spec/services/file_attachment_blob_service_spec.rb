# frozen_string_literal: true

RSpec.describe FileAttachmentBlobService do
  let(:file) { fixture_file_upload("files/text-file.txt") }

  describe "#blob_id" do
    it "returns the id for the newly created blob" do
      service = FileAttachmentBlobService.new(file: file)
      expect(service.blob_id).to be(ActiveStorage::Blob.last.id)
    end
  end

  describe "#blob_filename" do
    it "returns the file's filename" do
      service = FileAttachmentBlobService.new(file: file)
      expect(service.blob_filename).to eq(file.original_filename)
    end
  end
end
