# frozen_string_literal: true

RSpec.describe Versioned::ImageRevision do
  describe "#different_to?" do
    it "is true when update data is different" do
      revision1 = create(:versioned_image_revision, crop_x: 5)
      revision2 = revision1.dup
      revision2.crop_x = 6

      expect(revision1.different_to?(revision2)).to be true
    end

    it "is false when content is the same and only timestamps differ" do
      revision1 = create(:versioned_image_revision,
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
      create(:versioned_image_revision, alt_text: "Sunny day")
    end

    it "returns the current revision if the update does not change it's content" do
      revision = existing_revision.build_revision_update(
        { alt_text: existing_revision.alt_text },
        build(:user),
      )

      expect(revision).to be(existing_revision)
    end

    it "returns a new revision if the update changes content" do
      revision = existing_revision.build_revision_update(
        { alt_text: "Rainy day" },
        build(:user),
      )

      expect(revision).not_to be(existing_revision)
      expect(revision).to be_new_record
    end

    it "maintains the asset manager files by default" do
      revision = existing_revision.build_revision_update(
        { alt_text: "Rainy day" },
        build(:user),
      )

      expect(revision.asset_manager_variants.map(&:file))
        .to match(existing_revision.asset_manager_variants.map(&:file))
    end

    context "when keep_files is false" do
      it "creates new files for an update that changes content" do
        revision = existing_revision.build_revision_update(
          { alt_text: "Rainy day" },
          build(:user),
          keep_files: false,
        )

        expect(revision.asset_manager_variants.map(&:file))
          .to_not eq(existing_revision.asset_manager_variants.map(&:file))
      end

      it "doesn't do anything when a new revision isn't created" do
        variants = existing_revision.asset_manager_variants

        revision = existing_revision.build_revision_update(
          {},
          build(:user),
          keep_files: false,
        )

        expect(revision.asset_manager_variants).to eq(variants)
      end
    end
  end

  describe "#ensure_asset_manager_variants" do
    it "doesn't change the variants when they already exist" do
      image_revision = build(:versioned_image_revision)
      variants = image_revision.asset_manager_variants

      image_revision.ensure_asset_manager_variants

      expect(image_revision.asset_manager_variants).to eq(variants)
      expect(image_revision.asset_manager_variants.map(&:variant))
        .to match(Versioned::ImageRevision::ASSET_MANAGER_VARIANTS)
    end

    it "creates variants for those that don't exist" do
      image_revision = build(:versioned_image_revision,
                             asset_manager_variants: [])

      expect(image_revision.asset_manager_variants).to be_empty

      image_revision.ensure_asset_manager_variants

      expect(image_revision.asset_manager_variants.map(&:variant))
        .to match(Versioned::ImageRevision::ASSET_MANAGER_VARIANTS)
    end
  end

  describe "#bytes_for_asset_manager_variant" do
    let(:image_revision) { build(:versioned_image_revision) }

    it "returns a string of bytes for a known variant" do
      response = image_revision.bytes_for_asset_manager_variant("high_resolution")

      expect(response).to be_a(String)
    end

    it "raises an error for an unknown variant" do
      expect { image_revision.bytes_for_asset_manager_variant("huh") }
        .to raise_error("Unsupported image revision variant huh")
    end
  end

  describe "#asset_manager_url" do
    let(:image_revision) { build(:versioned_image_revision, :on_asset_manager) }

    it "returns a url for a known variant" do
      variant = image_revision.asset_manager_variants.first
      url = image_revision.asset_manager_url(variant.variant)

      expect(url).to match(%r{https://asset-manager})
      expect(url).to eq(variant.file_url)
    end

    it "returns nil for an unknown variant" do
      url = image_revision.asset_manager_url("unknown")

      expect(url).to be_nil
    end
  end
end
