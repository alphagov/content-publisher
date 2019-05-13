# frozen_string_literal: true

RSpec.describe Versioning::FileAttachmentRevisionUpdater do
  describe "#assign" do
    let(:user) { create :user }

    let(:revision) do
      create(
        :file_attachment_revision,
        title: "A title",
      )
    end

    it "raises an error for unexpected attributes" do
      updater = Versioning::FileAttachmentRevisionUpdater.new(revision, user)
      expect { updater.assign(foo: "bar") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "creates a new revision when a value changes" do
      updater = Versioning::FileAttachmentRevisionUpdater.new(revision, user)
      updater.assign(title: "Another title")

      next_revision = updater.next_revision
      expect(next_revision).to_not eq revision
      expect(next_revision.created_by).to eq user
    end

    it "updates and reports changes to the fields" do
      updater = Versioning::FileAttachmentRevisionUpdater.new(revision, user)

      updater.assign(title: "Another title")
      next_revision = updater.next_revision

      expect(updater.changed?).to be_truthy
      expect(updater.changes).to include(title: "Another title")

      expect(updater.changed?(:title)).to be_truthy
      expect(next_revision.public_send(:title)).to eq "Another title"
    end

    it "preserves the current revision if no change" do
      updater = Versioning::FileAttachmentRevisionUpdater.new(revision, user)
      updater.assign(title: revision.title)

      expect(updater.changed?).to be_falsey
      expect(updater.changes).to be_empty
      expect(updater.next_revision).to eq revision
    end
  end
end
