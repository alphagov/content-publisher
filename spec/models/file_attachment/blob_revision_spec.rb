# frozen_string_literal: true

RSpec.describe FileAttachment::BlobRevision do
  describe "#ensure_assets" do
    it "doesn't change the assets when they already exist" do
      blob_revision = build(:file_attachment_blob_revision)
      assets = blob_revision.assets.to_a

      blob_revision.ensure_assets

      expect(blob_revision.assets.to_a).to eq(assets)
      expect(blob_revision.assets.map(&:variant)).to match(%w[file])
    end

    it "creates variants for those that don't exist" do
      blob_revision = build(:file_attachment_blob_revision, assets: [])

      expect(blob_revision.assets).to be_empty

      blob_revision.ensure_assets

      expect(blob_revision.assets.map(&:variant)).to match(%w[file])
    end
  end

  describe "#bytes_for_asset" do
    let(:blob_revision) { build(:file_attachment_blob_revision) }

    it "returns a string of bytes for a known variant" do
      response = blob_revision.bytes_for_asset("file")

      expect(response).to be_a(String)
    end

    it "raises an error for an unknown variant" do
      expect { blob_revision.bytes_for_asset("huh") }
        .to raise_error("Unsupported blob revision variant huh")
    end
  end
end
