# frozen_string_literal: true

RSpec.describe Versioning::RevisionUpdater::FileAttachment do
  let(:user) { create :user }
  let(:file_attachment_revision) { create :file_attachment_revision }
  let(:revision) do
    create :revision, file_attachment_revisions: [file_attachment_revision]
  end

  describe "#add_file_attachment" do
    it "extends file attachment revisions with a new file attachment" do
      new_file_attachment = create :file_attachment_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.add_file_attachment(new_file_attachment)

      next_revision = updater.next_revision
      expect(next_revision.file_attachment_revisions)
        .to match_array [file_attachment_revision, new_file_attachment]
    end

    it "raises an error if a revision exists for the same attachment" do
      updater = Versioning::RevisionUpdater.new(revision, user)

      expect { updater.add_file_attachment(file_attachment_revision) }
        .to raise_error(RuntimeError, "Cannot add another revision for the same file attachment")
    end
  end
end
