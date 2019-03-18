# frozen_string_literal: true

RSpec.describe Versioning::RevisionUpdater::Image do
  let(:user) { create :user }
  let(:image_revision) { create :image_revision }

  describe "#update_image" do
    it "extends image revisions with a new image" do
      revision = create :revision, image_revisions: [image_revision]
      new_image = create :image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(new_image)

      next_revision = updater.next_revision
      expect(next_revision.image_revisions).to match_array [image_revision, new_image]
    end

    it "updates an existing image with a new revision" do
      revision = create :revision, image_revisions: [image_revision]
      updated_image = create :image_revision, image_id: image_revision.image_id

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image)

      next_revision = updater.next_revision
      expect(next_revision.image_revisions).to match_array [updated_image]
    end

    it "preserves another existing image as the lead" do
      revision = create :revision, lead_image_revision: image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(create(:image_revision))

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq image_revision
      expect(updater.selected_lead_image?).to be_falsey
      expect(updater.removed_lead_image?).to be_falsey
    end

    it "preserves the given image as the lead if selected" do
      revision = create :revision, lead_image_revision: image_revision
      updated_image = create :image_revision, image_id: image_revision.image_id

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image, true)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq updated_image
      expect(updater.selected_lead_image?).to be_falsey
      expect(updater.removed_lead_image?).to be_falsey
    end

    it "sets the given image as the lead if selected" do
      revision = create :revision
      updated_image = create :image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image, true)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq updated_image
      expect(updater.selected_lead_image?).to be_truthy
      expect(updater.removed_lead_image?).to be_falsey
    end

    it "unsets the given image as the lead if not selected" do
      revision = create :revision, lead_image_revision: image_revision
      updated_image = create :image_revision, image_id: image_revision.image_id

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to be_nil
      expect(updater.selected_lead_image?).to be_falsey
      expect(updater.removed_lead_image?).to be_truthy
    end
  end

  describe "#remove_image" do
    it "removes the image from the image revisions" do
      other_image_revision = create :image_revision
      revision = create :revision, image_revisions: [other_image_revision, image_revision]

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_image(image_revision)

      next_revision = updater.next_revision
      expect(next_revision.image_revisions).to match_array [other_image_revision]
    end

    it "preserves another existing image as the lead" do
      other_image_revision = create :image_revision
      revision = create :revision, lead_image_revision: other_image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_image(image_revision)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq other_image_revision
      expect(updater.selected_lead_image?).to be_falsey
      expect(updater.removed_lead_image?).to be_falsey
    end

    it "unsets the given image if it was the lead" do
      revision = create :revision, lead_image_revision: image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_image(image_revision)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to be_nil
      expect(updater.selected_lead_image?).to be_falsey
      expect(updater.removed_lead_image?).to be_truthy
    end
  end
end
