# frozen_string_literal: true

RSpec.describe Versioning::RevisionUpdater do
  describe "#assign" do
    let(:user) { create :user }

    let(:revision) do
      create(
        :revision,
        number: 1,
        title: "old title",
        tags: { old: "tag" },
        change_note: "old change note",
        lead_image_revision: (create :image_revision),
        image_revisions: [create(:image_revision)],
        file_attachment_revisions: [create(:file_attachment_revision)],
      )
    end

    it "raises an error for unexpected attributes" do
      updater = Versioning::RevisionUpdater.new(revision, user)
      expect { updater.assign(foo: "bar") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "creates a new revision when a value changes" do
      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.assign(title: "new title")

      next_revision = updater.next_revision
      expect(next_revision).to_not eq revision
      expect(next_revision.created_by).to eq user
      expect(next_revision.number).to eq 2
      expect(next_revision.preceded_by).to eq revision
    end

    it "updates and reports changes to the fields" do
      updater = Versioning::RevisionUpdater.new(revision, user)

      new_fields = {
        title: "new title",
        tags: { "new_tag" => [] },
        change_note: "new change note",
        lead_image_revision: nil,
        image_revisions: [],
        file_attachment_revisions: [],
      }

      updater.assign(new_fields)
      next_revision = updater.next_revision

      expect(updater.changed?).to be_truthy
      expect(updater.changes).to include(new_fields)

      new_fields.each do |name, value|
        expect(updater.changed?(name)).to be_truthy
        expect(next_revision.public_send(name)).to eq value
      end
    end

    it "preserves the current revision if no change" do
      updater = Versioning::RevisionUpdater.new(revision, user)

      old_fields = {
        title: revision.title,
        tags: revision.tags,
        change_note: revision.change_note,
        lead_image_revision: revision.lead_image_revision,
        image_revisions: revision.image_revisions,
        file_attachment_revisions: revision.file_attachment_revisions,
      }

      updater.assign(old_fields)
      expect(updater.changed?).to be_falsey
      expect(updater.changes).to be_empty
      expect(updater.next_revision).to eq revision
    end

    it "preserves existing values when others change" do
      updater = Versioning::RevisionUpdater.new(revision, user)

      old_fields = {
        title: revision.title,
        tags: revision.tags,
        change_note: revision.change_note,
        lead_image_revision: revision.lead_image_revision,
        image_revisions: revision.image_revisions,
        file_attachment_revisions: revision.file_attachment_revisions,
      }

      updater.assign(summary: "new summary")
      next_revision = updater.next_revision

      expect(next_revision).to_not eq revision

      old_fields.each do |name, value|
        expect(next_revision.public_send(name)).to eq value
      end
    end
  end
end
