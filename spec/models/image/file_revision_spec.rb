# frozen_string_literal: true

RSpec.describe Image::FileRevision do
  describe "#ensure_assets" do
    it "doesn't change the assets when they already exist" do
      image_revision = build(:image_file_revision)
      assets = image_revision.assets

      image_revision.ensure_assets

      expect(image_revision.assets).to be(assets)
      expect(image_revision.assets.map(&:variant))
        .to match(Image::FileRevision::ASSET_VARIANTS)
    end

    it "creates variants for those that don't exist" do
      image_revision = build(:image_file_revision, assets: [])

      expect(image_revision.assets).to be_empty

      image_revision.ensure_assets

      expect(image_revision.assets.map(&:variant))
        .to match(Image::FileRevision::ASSET_VARIANTS)
    end
  end

  describe "#bytes_for_asset" do
    let(:image_revision) { build(:image_file_revision) }

    it "returns a string of bytes for a known variant" do
      response = image_revision.bytes_for_asset("high_resolution")

      expect(response).to be_a(String)
    end

    it "raises an error for an unknown variant" do
      expect { image_revision.bytes_for_asset("huh") }
        .to raise_error("Unsupported image revision variant huh")
    end
  end

  describe "#asset_url" do
    let(:image_revision) { build(:image_file_revision, :on_asset_manager) }

    it "returns a url for a known variant" do
      asset = image_revision.assets.first
      url = image_revision.asset_url(asset.variant)

      expect(url).to match(%r{https://asset-manager})
      expect(url).to eq(asset.file_url)
    end

    it "returns nil for an unknown variant" do
      url = image_revision.asset_url("unknown")

      expect(url).to be_nil
    end
  end
end
