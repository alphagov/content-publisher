# frozen_string_literal: true

RSpec.describe Versioned::Image::Revision do
  describe "#different_to?" do
    it "errors if the item being compared to isn't persisted" do
      expect { Versioned::Image::Revision.new.different_to?(build(:versioned_image_revision)) }
        .to raise_error("Must compare with a persisted record")
    end

    it "is false if the same revisions are used" do
      old_revision = create(:versioned_image_revision)
      new_revision = create(:versioned_image_revision,
                            image: old_revision.image,
                            file_revision: old_revision.file_revision,
                            metadata_revision: old_revision.metadata_revision)

      expect(new_revision.different_to?(old_revision)).to be false
    end

    it "is true if there are different revisions" do
      old_revision = create(:versioned_image_revision)
      new_revision = create(:versioned_image_revision,
                            image: old_revision.image,
                            file_revision: old_revision.file_revision,
                            metadata_revision: build(:versioned_image_metadata_revision))

      expect(new_revision.different_to?(old_revision)).to be true
    end
  end

  describe "#build_revision_update" do
    let(:user) { build(:user) }

    it "errors if the revision isn't persisted" do
      expect { Versioned::Image::Revision.new.build_revision_update({}, user) }
        .to raise_error("Can't update from an unpersisted record")
    end

    it "returns the same revision if there are no changes" do
      revision = create(:versioned_image_revision, alt_text: "Alt")

      expect(revision.build_revision_update({ alt_text: "Alt" }, user))
        .to be(revision)
    end

    it "returns a new revision if there are changes" do
      revision = create(:versioned_image_revision, alt_text: "Alt")
      new_revision = revision.build_revision_update(
        { alt_text: "Different" },
        user,
      )

      expect(new_revision).to be_new_record
      expect(new_revision).to be_a(Versioned::Image::Revision)
      expect(new_revision.alt_text).to eq("Different")
      expect(new_revision.created_by).to eq(user)
    end

    it "includes a new file revision when those attributes are updated" do
      revision = create(:versioned_image_revision)
      update = { crop_x: 100, crop_y: 100 }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.file_revision).not_to eq(revision.file_revision)
      expect(new_revision.metadata_revision).to eq(revision.metadata_revision)
    end

    it "includes a new metadata revision when those attributes are updated" do
      revision = create(:versioned_image_revision)
      update = { caption: "My Caption" }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.file_revision).to eq(revision.file_revision)
      expect(new_revision.metadata_revision).not_to eq(revision.metadata_revision)
    end
  end
end
