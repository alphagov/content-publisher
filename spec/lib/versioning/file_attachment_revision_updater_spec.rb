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
      updater = described_class.new(revision, user)
      expect { updater.assign(foo: "bar") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "creates a new revision when a value changes" do
      updater = described_class.new(revision, user)
      updater.assign(title: "Another title")

      next_revision = updater.next_revision
      expect(next_revision).not_to eq revision
      expect(next_revision.created_by).to eq user
    end

    it "updates and reports changes to the fields" do
      updater = described_class.new(revision, user)

      new_fields = { title: "Another title" }

      updater.assign(new_fields)
      next_revision = updater.next_revision

      expect(updater).to be_changed
      expect(updater.changes).to include(new_fields)
      expect(updater).to be_changed(:title)
      expect(next_revision.public_send(:title)).to eq "Another title"
    end

    it "preserves the current revision if no change" do
      updater = described_class.new(revision, user)
      new_fields = { title: revision.title }

      updater.assign(new_fields)
      expect(updater).not_to be_changed
      expect(updater.changes).to be_empty
      expect(updater.next_revision).to eq revision
    end

    it "preserves existing values when others change" do
      updater = described_class.new(revision, user)

      old_fields = {
        blob_id: revision.blob_revision.blob.id,
        number_of_pages: revision.number_of_pages,
      }

      updater.assign(title: "A new title")
      next_revision = updater.next_revision

      expect(next_revision).not_to eq revision
      expect(next_revision.blob_revision.blob_id).to eq(old_fields[:blob_id])
      expect(next_revision.number_of_pages).to eq(old_fields[:number_of_pages])
    end

    it "can accept a blob_revision as an attribute" do
      updater = described_class.new(revision, user)
      blob_revision = create(:file_attachment_blob_revision, filename: "new-file.txt")
      updater.assign(blob_revision: blob_revision)

      expect(updater.next_revision.blob_revision).to eq(blob_revision)
      expect(updater.next_revision).not_to eq(revision)
      expect(updater.changes).to match(a_hash_including(blob_revision: blob_revision))
    end
  end
end
