# frozen_string_literal: true

RSpec.describe Versioned::Image::MetadataRevision do
  describe "#different_to?" do
    it "is true when metadata is different" do
      revision1 = build(:versioned_image_metadata_revision, alt_text: "this")
      revision2 = build(:versioned_image_metadata_revision, alt_text: "that")

      expect(revision1.different_to?(revision2)).to be true
    end

    it "is false when metadata is the same and only timestamps differ" do
      revision1 = build(:versioned_image_metadata_revision,
                        credit: "Getty",
                        created_at: 10.days.ago)
      revision2 = build(:versioned_image_metadata_revision,
                        credit: "Getty",
                        created_at: 10.weeks.ago)
      expect(revision1.different_to?(revision2)).to be false
    end
  end

  describe "#build_revision_update" do
    let(:existing_revision) do
      create(:versioned_image_metadata_revision, caption: "Great shot")
    end

    it "returns the current revision if the update does not change the contents" do
      revision = existing_revision.build_revision_update(
        { caption: existing_revision.caption },
        build(:user),
      )

      expect(revision).to be(existing_revision)
    end

    it "returns a new revision if the update changes content" do
      revision = existing_revision.build_revision_update(
        { caption: "Better shot" },
        build(:user),
      )

      expect(revision).not_to be(existing_revision)
      expect(revision).to be_new_record
    end
  end
end
