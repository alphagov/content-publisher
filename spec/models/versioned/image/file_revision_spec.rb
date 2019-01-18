# frozen_string_literal: true

RSpec.describe Versioned::Image::FileRevision do
  describe "#different_to?" do
    it "is true when update data is different" do
      revision1 = create(:versioned_image_file_revision, crop_x: 5)
      revision2 = revision1.dup
      revision2.crop_x = 6

      expect(revision1.different_to?(revision2)).to be true
    end

    it "is false when content is the same and only timestamps differ" do
      revision1 = create(:versioned_image_file_revision,
                         crop_x: 5,
                         created_at: 10.days.ago)
      revision2 = revision1.dup
      revision2.crop_x = 5
      revision2.created_at = 10.seconds.ago

      expect(revision1.different_to?(revision2)).to be false
    end
  end

  describe "#build_revision_update" do
    let(:existing_revision) do
      create(:versioned_image_file_revision, crop_y: 10)
    end

    it "returns the current revision if the update does not change it's content" do
      revision = existing_revision.build_revision_update(
        { crop_y: existing_revision.crop_y },
        build(:user),
      )

      expect(revision).to be(existing_revision)
    end

    it "returns a new revision if the update changes content" do
      revision = existing_revision.build_revision_update(
        { crop_y: 200 },
        build(:user),
      )

      expect(revision).not_to be(existing_revision)
      expect(revision).to be_new_record
    end

    it "creates new assets for a change" do
      revision = existing_revision.build_revision_update(
        { crop_y: 200 },
        build(:user),
      )

      expect(revision.assets).not_to match(existing_revision.assets)
    end
  end

  describe "#ensure_assets" do
    it "doesn't change the assets when they already exist" do
      image_revision = build(:versioned_image_file_revision)
      assets = image_revision.assets

      image_revision.ensure_assets

      expect(image_revision.assets).to be(assets)
      expect(image_revision.assets.map(&:variant))
        .to match(Versioned::Image::FileRevision::ASSET_VARIANTS)
    end

    it "creates variants for those that don't exist" do
      image_revision = build(:versioned_image_file_revision, assets: [])

      expect(image_revision.assets).to be_empty

      image_revision.ensure_assets

      expect(image_revision.assets.map(&:variant))
        .to match(Versioned::Image::FileRevision::ASSET_VARIANTS)
    end
  end

  describe "#bytes_for_asset" do
    let(:image_revision) { build(:versioned_image_file_revision) }

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
    let(:image_revision) { build(:versioned_image_file_revision, :on_asset_manager) }

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
