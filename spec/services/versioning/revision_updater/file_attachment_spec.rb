# frozen_string_literal: true

RSpec.describe Versioning::RevisionUpdater::FileAttachment do
  let(:user) { create :user }
  let(:file_attachment_revision) { create :file_attachment_revision }
  let(:revision) do
    create :revision, file_attachment_revisions: [file_attachment_revision]
  end

  describe "#update_file_attachment" do
    it "extends file attachment revisions with a new file attachment" do
      new_file_attachment = create :file_attachment_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_file_attachment(new_file_attachment)

      next_revision = updater.next_revision
      expect(next_revision.file_attachment_revisions)
        .to match_array [file_attachment_revision, new_file_attachment]
    end

    it "updates an existing file attachment with a new revision" do
      updated_file_attachment = create :file_attachment_revision,
                                file_attachment_id: file_attachment_revision.file_attachment_id

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_file_attachment(updated_file_attachment)

      next_revision = updater.next_revision
      expect(next_revision.file_attachment_revisions)
        .to match_array [updated_file_attachment]
    end
  end
end
