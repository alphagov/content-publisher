# frozen_string_literal: true

RSpec.describe FileAttachment::BlobRevision do
  describe "#bytes_for_asset" do
    let(:blob_revision) { build(:file_attachment_blob_revision) }

    it "returns a string of bytes" do
      response = blob_revision.bytes_for_asset

      expect(response).to be_a(String)
    end
  end
end
