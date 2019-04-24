# frozen_string_literal: true

RSpec.describe FileAttachment::FileRevision do
  describe "#ensure_assets" do
    it "doesn't change the assets when they already exist" do
      file_revision = build(:file_attachment_file_revision)
      assets = file_revision.assets.to_a

      file_revision.ensure_assets

      expect(file_revision.assets.to_a).to eq(assets)
      expect(file_revision.assets.map(&:variant)).to match(%w[file])
    end

    it "creates variants for those that don't exist" do
      file_revision = build(:file_attachment_file_revision, assets: [])

      expect(file_revision.assets).to be_empty

      file_revision.ensure_assets

      expect(file_revision.assets.map(&:variant)).to match(%w[file])
    end
  end

  describe "#bytes_for_asset" do
    let(:file_revision) { build(:file_attachment_file_revision) }

    it "returns a string of bytes for a known variant" do
      response = file_revision.bytes_for_asset("file")

      expect(response).to be_a(String)
    end

    it "raises an error for an unknown variant" do
      expect { file_revision.bytes_for_asset("huh") }
        .to raise_error("Unsupported file revision variant huh")
    end
  end
end
