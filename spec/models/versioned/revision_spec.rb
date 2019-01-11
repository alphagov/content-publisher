# frozen_string_literal: true

RSpec.describe Versioned::Revision do
  describe ".create_initial" do
    let(:document) { build(:versioned_document) }

    it "creates an empty revision for the document" do
      revision = Versioned::Revision.create_initial(document)

      expect(revision).to be_a(Versioned::Revision)
      expect(revision).not_to be_new_record
      expect(revision.document).to eq(document)
      expect(revision.title).to be_nil
    end

    it "sets default change note and update type" do
      revision = Versioned::Revision.create_initial(document)

      expect(revision.change_note).to eq("First published.")
      expect(revision.update_type).to eq("major")
    end

    it "can associate records with a user" do
      user = build(:user)
      revision = Versioned::Revision.create_initial(document, user)

      expect(revision.created_by).to eq(user)
      expect(revision.content_revision.created_by).to eq(user)
      expect(revision.tags_revision.created_by).to eq(user)
      expect(revision.update_revision.created_by).to eq(user)
    end

    it "can set tags" do
      tags = { "type" => %w[value1 value2] }
      revision = Versioned::Revision.create_initial(document, nil, tags)

      expect(revision.tags).to eq(tags)
    end
  end

  describe "#different_to?" do
    it "errors if the item being compared to isn't persisted" do
      expect { Versioned::Revision.new.different_to?(build(:versioned_revision)) }
        .to raise_error("Must compare with a persisted record")
    end

    it "is false if the same revisions are used" do
      old_revision = create(:versioned_revision, lead_image_revision: nil)
      new_revision = create(:versioned_revision,
                            document: old_revision.document,
                            content_revision: old_revision.content_revision,
                            tags_revision: old_revision.tags_revision,
                            update_revision: old_revision.update_revision,
                            lead_image_revision: nil)

      expect(new_revision.different_to?(old_revision)).to be false
    end

    it "is true if there are different revisions" do
      old_revision = create(:versioned_revision, lead_image_revision: nil)
      new_revision = create(:versioned_revision,
                            document: old_revision.document,
                            content_revision: build(:versioned_content_revision),
                            tags_revision: old_revision.tags_revision,
                            update_revision: old_revision.update_revision,
                            lead_image_revision: nil)

      expect(new_revision.different_to?(old_revision)).to be true
    end

    it "is true if there are different image revisions" do
      old_revision = create(:versioned_revision,
                            lead_image_revision: nil,
                            image_revisions: [build(:versioned_image_revision)])
      new_revision = create(:versioned_revision,
                            document: old_revision.document,
                            content_revision: old_revision.content_revision,
                            tags_revision: old_revision.tags_revision,
                            update_revision: old_revision.update_revision,
                            lead_image_revision: nil,
                            image_revisions: [build(:versioned_image_revision)])

      expect(new_revision.different_to?(old_revision)).to be true
    end
  end

  describe "#build_revision_update" do
    let(:user) { build(:user) }

    it "errors if the revision isn't persisted" do
      expect { Versioned::Revision.new.build_revision_update({}, user) }
        .to raise_error("Can't update from an unpersisted record")
    end

    it "returns the same revision if there are no changes" do
      revision = create(:versioned_revision, title: "My Title")

      expect(revision.build_revision_update({ title: "My Title" }, user))
        .to be(revision)
    end

    it "returns a new revision if there are changes" do
      revision = create(:versioned_revision, title: "My Title")
      new_revision = revision.build_revision_update({ title: "Blah" }, user)

      expect(new_revision).to be_new_record
      expect(new_revision).to be_a(Versioned::Revision)
      expect(new_revision.title).to eq("Blah")
      expect(new_revision.created_by).to eq(user)
      expect(new_revision.preceded_by).to eq(revision)
    end

    it "includes a new content revision when those attributes are updated" do
      revision = create(:versioned_revision)
      update = { title: "New", summary: "New", base_path: "/new", contents: {} }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.content_revision).not_to eq(revision.content_revision)
      expect(new_revision.tags_revision).to eq(revision.tags_revision)
      expect(new_revision.update_revision).to eq(revision.update_revision)
    end

    it "includes a new tags revision when tags are updated" do
      revision = create(:versioned_revision)
      update = { tags: { field: %w[values] } }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.content_revision).to eq(revision.content_revision)
      expect(new_revision.tags_revision).not_to eq(revision.tags_revision)
      expect(new_revision.update_revision).to eq(revision.update_revision)
    end

    it "includes a new update revision when those attributes are updated" do
      revision = create(:versioned_revision)
      update = { change_note: "Changed", update_type: :minor }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.content_revision).to eq(revision.content_revision)
      expect(new_revision.tags_revision).to eq(revision.tags_revision)
      expect(new_revision.update_revision).not_to eq(revision.update_revision)
    end

    it "can retain image revisions" do
      image_revision = create(:versioned_image_revision)
      revision = create(:versioned_revision,
                        lead_image_revision: image_revision,
                        image_revisions: [image_revision])
      new_revision = revision.build_revision_update({}, user)

      expect(new_revision.lead_image_revision).to eq(image_revision)
      expect(new_revision.image_revisions).to match([image_revision])
    end

    it "can change image revisions" do
      image_revision1 = create(:versioned_image_revision)
      revision = create(:versioned_revision,
                        lead_image_revision: image_revision1,
                        image_revisions: [image_revision1])

      image_revision2 = create(:versioned_image_revision)
      new_revision = revision.build_revision_update(
        {
          lead_image_revision: image_revision2,
          image_revisions: [image_revision1, image_revision2],
        },
        user,
      )

      expect(new_revision.lead_image_revision).to eq(image_revision2)
      expect(new_revision.image_revisions)
        .to match([image_revision1, image_revision2])
    end

    it "can change image revisions by id" do
      image_revision1 = create(:versioned_image_revision)
      revision = create(:versioned_revision,
                        lead_image_revision: image_revision1,
                        image_revisions: [image_revision1])

      image_revision2 = create(:versioned_image_revision)
      new_revision = revision.build_revision_update(
        {
          lead_image_revision_id: image_revision2.id,
          image_revision_ids: [image_revision1.id, image_revision2.id],
        },
        user,
      )

      expect(new_revision.lead_image_revision).to eq(image_revision2)
      expect(new_revision.image_revisions)
        .to match([image_revision1, image_revision2])
    end
  end

  describe "#build_revision_update_for_image_upsert" do
    let(:user) { create(:user) }

    it "returns a new revision with the image included" do
      image_revision = create(:versioned_image_revision)
      revision = create(:versioned_revision,
                        lead_image_revision: nil,
                        image_revisions: [])

      new_revision = revision.build_revision_update_for_image_upsert(
        image_revision,
        user,
      )

      expect(new_revision).to be_a(Versioned::Revision)
      expect(new_revision).to be_new_record
      expect(new_revision.created_by).to eq(user)
      expect(new_revision.lead_image_revision).to be_nil
      expect(new_revision.image_revisions).to match([image_revision])
    end

    it "can replace newer revisions of images" do
      image_revision1 = create(:versioned_image_revision)
      image_revision2 = create(:versioned_image_revision,
                               image: image_revision1.image)
      revision = create(:versioned_revision,
                        lead_image_revision: image_revision1,
                        image_revisions: [image_revision1])

      new_revision = revision.build_revision_update_for_image_upsert(
        image_revision2,
        user,
      )

      expect(new_revision.lead_image_revision).to eq(image_revision2)
      expect(new_revision.image_revisions).to match([image_revision2])
    end
  end

  describe "#build_revision_update_for_image_removed" do
    let(:user) { create(:user) }

    it "returns a new revision with the image removed" do
      image_revision = create(:versioned_image_revision)
      revision = create(:versioned_revision,
                        lead_image_revision: nil,
                        image_revisions: [image_revision])

      new_revision = revision.build_revision_update_for_image_removed(
        image_revision,
        user,
      )

      expect(new_revision).to be_a(Versioned::Revision)
      expect(new_revision).to be_new_record
      expect(new_revision.created_by).to eq(user)
      expect(new_revision.lead_image_revision).to be_nil
      expect(new_revision.image_revisions).to be_empty
    end

    it "will remove lead image" do
      image_revision1 = create(:versioned_image_revision)
      image_revision2 = create(:versioned_image_revision)
      revision = create(:versioned_revision,
                        lead_image_revision: image_revision1,
                        image_revisions: [image_revision1, image_revision2])

      new_revision = revision.build_revision_update_for_image_removed(
        image_revision1,
        user,
      )

      expect(new_revision.lead_image_revision).to be_nil
      expect(new_revision.image_revisions).to match([image_revision2])
    end

    it "doesn't return a new revision if the image_revision isn't there" do
      image_revision = create(:versioned_image_revision)
      revision = create(:versioned_revision)

      new_revision = revision.build_revision_update_for_image_removed(
        image_revision,
        user,
      )

      expect(new_revision).to be(revision)
    end
  end
end
