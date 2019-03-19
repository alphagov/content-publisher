# frozen_string_literal: true

RSpec.describe Revision do
  include ActiveSupport::Testing::TimeHelpers

  describe ".create_initial" do
    let(:document) { build(:document) }

    it "creates an empty revision for the document" do
      revision = Revision.create_initial(document)

      expect(revision).to be_a(Revision)
      expect(revision).not_to be_new_record
      expect(revision.document).to eq(document)
      expect(revision.title).to be_nil
    end

    it "sets default change note and update type" do
      revision = Revision.create_initial(document)

      expect(revision.change_note).to eq("First published.")
      expect(revision.update_type).to eq("major")
    end

    it "can associate records with a user" do
      user = build(:user)
      revision = Revision.create_initial(document, user)

      expect(revision.created_by).to eq(user)
      expect(revision.content_revision.created_by).to eq(user)
      expect(revision.metadata_revision.created_by).to eq(user)
      expect(revision.tags_revision.created_by).to eq(user)
    end

    it "can set tags" do
      tags = { "type" => %w[value1 value2] }
      revision = Revision.create_initial(document, nil, tags)

      expect(revision.tags).to eq(tags)
    end
  end

  describe "#different_to?" do
    it "errors if the item being compared to isn't persisted" do
      expect { Revision.new.different_to?(build(:revision)) }
        .to raise_error("Must compare with a persisted record")
    end

    it "is false if the same revisions are used" do
      old_revision = create(:revision, lead_image_revision: nil)
      new_revision = create(:revision,
                            document: old_revision.document,
                            content_revision: old_revision.content_revision,
                            tags_revision: old_revision.tags_revision,
                            metadata_revision: old_revision.metadata_revision,
                            lead_image_revision: nil)

      expect(new_revision.different_to?(old_revision)).to be false
    end

    it "is true if there are different revisions" do
      old_revision = create(:revision, lead_image_revision: nil)
      new_revision = create(:revision,
                            document: old_revision.document,
                            content_revision: build(:content_revision),
                            tags_revision: old_revision.tags_revision,
                            metadata_revision: old_revision.metadata_revision,
                            lead_image_revision: nil)

      expect(new_revision.different_to?(old_revision)).to be true
    end

    it "is true if there are different image revisions" do
      old_revision = create(:revision,
                            lead_image_revision: nil,
                            image_revisions: [build(:image_revision)])
      new_revision = create(:revision,
                            document: old_revision.document,
                            content_revision: old_revision.content_revision,
                            tags_revision: old_revision.tags_revision,
                            metadata_revision: old_revision.metadata_revision,
                            lead_image_revision: nil,
                            image_revisions: [build(:image_revision)])

      expect(new_revision.different_to?(old_revision)).to be true
    end
  end

  describe "#build_revision_update" do
    let(:user) { build(:user) }

    it "errors if the revision isn't persisted" do
      expect { Revision.new.build_revision_update({}, user) }
        .to raise_error("Can't update from an unpersisted record")
    end

    it "returns the same revision if there are no changes" do
      revision = create(:revision, title: "My Title")

      expect(revision.build_revision_update({ title: "My Title" }, user))
        .to be(revision)
    end

    it "returns a new revision if there are changes" do
      revision = create(:revision, title: "My Title")
      new_revision = revision.build_revision_update({ title: "Blah" }, user)

      expect(new_revision).to be_new_record
      expect(new_revision).to be_a(Revision)
      expect(new_revision.title).to eq("Blah")
      expect(new_revision.created_by).to eq(user)
      expect(new_revision.preceded_by).to eq(revision)
    end

    it "includes a new content revision when those attributes are updated" do
      revision = create(:revision)
      update = { title: "New", summary: "New", base_path: "/new", contents: {} }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.content_revision).not_to eq(revision.content_revision)
      expect(new_revision.metadata_revision).to eq(revision.metadata_revision)
      expect(new_revision.tags_revision).to eq(revision.tags_revision)
    end

    it "includes a new tags revision when tags are updated" do
      revision = create(:revision)
      update = { tags: { field: %w[values] } }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.content_revision).to eq(revision.content_revision)
      expect(new_revision.metadata_revision).to eq(revision.metadata_revision)
      expect(new_revision.tags_revision).not_to eq(revision.tags_revision)
    end

    it "includes a new update revision when those attributes are updated" do
      revision = create(:revision)
      update = { change_note: "Changed", update_type: :minor }
      new_revision = revision.build_revision_update(update, user)

      expect(new_revision.content_revision).to eq(revision.content_revision)
      expect(new_revision.metadata_revision).not_to eq(revision.metadata_revision)
      expect(new_revision.tags_revision).to eq(revision.tags_revision)
    end

    it "can retain image revisions" do
      image_revision = create(:image_revision)
      revision = create(:revision,
                        lead_image_revision: image_revision,
                        image_revisions: [image_revision])
      new_revision = revision.build_revision_update({}, user)

      expect(new_revision.lead_image_revision).to eq(image_revision)
      expect(new_revision.image_revisions).to match([image_revision])
    end

    it "can change image revisions" do
      image_revision1 = create(:image_revision)
      revision = create(:revision,
                        lead_image_revision: image_revision1,
                        image_revisions: [image_revision1])

      image_revision2 = create(:image_revision)
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
  end

  describe "#assign_revision" do
    context "when an edition is live" do
      it "raises an error" do
        edition = build(:edition, :published)

        expect { edition.assign_revision(build(:revision), build(:user)) }
          .to raise_error(RuntimeError, "cannot update revision on a live edition")
      end
    end

    context "when an edition is not live" do
      it "sets the revision" do
        edition = build(:edition)
        revision = build(:revision)

        edition.assign_revision(revision, build(:user))
        expect(edition.revision).to be(revision)
      end

      it "sets who last edited it" do
        edition = build(:edition)
        user = build(:user)

        edition.assign_revision(build(:revision), user)
        expect(edition.last_edited_by).to be(user)
      end

      it "sets the last edited time" do
        edition = build(:edition)

        travel_to(Time.current) do
          edition.assign_revision(build(:revision), build(:user))

          expect(edition.last_edited_at).to eq(Time.current)
        end
      end

      it "does not save the record" do
        edition = build(:edition)

        edition.assign_revision(build(:revision), build(:user))

        expect(edition).to be_new_record
      end
    end
  end
end
