RSpec.describe Versioning::RevisionUpdater::Image do
  let(:user) { create :user }
  let(:image_revision) { create :image_revision }

  describe "#add_image" do
    it "extends image revisions with a new image" do
      revision = create :revision, image_revisions: [image_revision]
      new_image = create :image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.add_image(new_image)

      next_revision = updater.next_revision
      expect(next_revision.image_revisions).to contain_exactly(image_revision, new_image)
    end

    it "raises an error if the image already exists" do
      revision = create :revision, image_revisions: [image_revision]
      updater = Versioning::RevisionUpdater.new(revision, user)

      expect { updater.add_image(image_revision) }
        .to raise_error(RuntimeError, "Cannot add another revision for the same image")
    end
  end

  describe "#update_image" do
    it "updates an existing image with a new revision" do
      revision = create :revision, image_revisions: [image_revision]
      updated_image = create :image_revision, image_id: image_revision.image_id

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image)

      next_revision = updater.next_revision
      expect(next_revision.image_revisions).to contain_exactly(updated_image)
    end

    it "raises an error if there is no image to update" do
      revision = create :revision
      updater = Versioning::RevisionUpdater.new(revision, user)

      expect { updater.update_image(image_revision) }
        .to raise_error(RuntimeError, "Cannot update an image that doesn't exist")
    end

    it "preserves another existing image as the lead" do
      other_image_revision = create :image_revision
      updated_image = create :image_revision, image_id: other_image_revision.image_id

      revision = create :revision, image_revisions: [image_revision, other_image_revision],
                                   lead_image_revision: image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq image_revision
      expect(updater).not_to be_selected_lead_image
      expect(updater).not_to be_removed_lead_image
    end

    it "replaces the lead image revision with the updated revision" do
      updated_image = create :image_revision, image_id: image_revision.image_id
      revision = create :revision, image_revisions: [image_revision],
                                   lead_image_revision: image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_image(updated_image)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq updated_image
      expect(updater).not_to be_selected_lead_image
      expect(updater).not_to be_removed_lead_image
    end

    describe "#update_lead_image" do
      it "preserves the given image as the lead if selected" do
        revision = create :revision, image_revisions: [image_revision],
                                     lead_image_revision: image_revision

        updated_image = create :image_revision, image_id: image_revision.image_id
        updater = Versioning::RevisionUpdater.new(revision, user)
        updater.assign_lead_image(updated_image, true)

        next_revision = updater.next_revision
        expect(next_revision.lead_image_revision).to eq updated_image
        expect(updater).not_to be_selected_lead_image
        expect(updater).not_to be_removed_lead_image
      end

      it "sets the given image as the lead if selected" do
        revision = create :revision, image_revisions: [image_revision]
        updated_image = create :image_revision, image_id: image_revision.image_id

        updater = Versioning::RevisionUpdater.new(revision, user)
        updater.assign_lead_image(updated_image, true)

        next_revision = updater.next_revision
        expect(next_revision.lead_image_revision).to eq updated_image
        expect(updater).to be_selected_lead_image
        expect(updater).not_to be_removed_lead_image
      end

      it "unsets the given image as the lead if not selected" do
        revision = create :revision, image_revisions: [image_revision],
                                     lead_image_revision: image_revision

        updated_image = create :image_revision, image_id: image_revision.image_id
        updater = Versioning::RevisionUpdater.new(revision, user)
        updater.assign_lead_image(updated_image, false)

        next_revision = updater.next_revision
        expect(next_revision.lead_image_revision).to be_nil
        expect(updater).not_to be_selected_lead_image
        expect(updater).to be_removed_lead_image
      end
    end
  end

  describe "#remove_image" do
    it "removes the image from the image revisions" do
      other_image_revision = create :image_revision
      revision = create :revision, image_revisions: [other_image_revision, image_revision]

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_image(image_revision)

      next_revision = updater.next_revision
      expect(next_revision.image_revisions).to contain_exactly(other_image_revision)
    end

    it "preserves another existing image as the lead" do
      other_image_revision = create :image_revision
      revision = create :revision, lead_image_revision: other_image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_image(image_revision)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to eq other_image_revision
      expect(updater).not_to be_selected_lead_image
      expect(updater).not_to be_removed_lead_image
    end

    it "unsets the given image if it was the lead" do
      revision = create :revision, lead_image_revision: image_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_image(image_revision)

      next_revision = updater.next_revision
      expect(next_revision.lead_image_revision).to be_nil
      expect(updater).not_to be_selected_lead_image
      expect(updater).to be_removed_lead_image
    end
  end
end
