# frozen_string_literal: true

RSpec.describe FileAttachment::FileRevision do
  describe "#ensure_assets" do
    it "doesn't change an asset that already exists" do
      file_revision = build(:file_attachment_file_revision)
      file_asset = file_revision.file_asset

      file_revision.ensure_assets

      expect(file_revision.file_asset).to be(file_asset)
    end

    it "creates a file asset if it doesn't exist" do
      file_revision = build(:file_attachment_file_revision)
      file_revision.file_asset = nil

      file_revision.ensure_assets

      expect(file_revision.file_asset).not_to be_nil
      expect(file_revision.file_asset.variant).to eq("file")
    end
  end
end
