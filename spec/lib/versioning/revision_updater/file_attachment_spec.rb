RSpec.describe Versioning::RevisionUpdater::FileAttachment do
  let(:user) { create :user }
  let(:attachment_revision) { create :file_attachment_revision }

  describe "#add_file_attachment" do
    it "extends file attachment revisions with a new file attachment" do
      revision = create :revision, file_attachment_revisions: [attachment_revision]
      new_attachment = create :file_attachment_revision

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.add_file_attachment(new_attachment)

      next_revision = updater.next_revision
      expect(next_revision.file_attachment_revisions)
        .to match_array [attachment_revision, new_attachment]
    end

    it "appends to the ordering when there are featured attachments" do
      document_type = build :document_type, attachments: "featured"
      ordering = [attachment_revision.featured_attachment_id]
      new_attachment = create :file_attachment_revision

      revision = create :revision,
                        document_type: document_type,
                        file_attachment_revisions: [attachment_revision],
                        featured_attachment_ordering: ordering

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.add_file_attachment(new_attachment)

      next_revision = updater.next_revision
      expect(next_revision.featured_attachment_ordering)
        .to eq ordering + [new_attachment.featured_attachment_id]
    end

    it "preserves the ordering when there are no featured attachments" do
      revision = create :revision
      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.add_file_attachment(attachment_revision)

      next_revision = updater.next_revision
      expect(next_revision.featured_attachment_ordering).to be_empty
    end

    it "raises an error if a revision exists for the same attachment" do
      revision = create :revision, file_attachment_revisions: [attachment_revision]
      updater = Versioning::RevisionUpdater.new(revision, user)

      expect { updater.add_file_attachment(attachment_revision) }
        .to raise_error(RuntimeError, "Cannot add another revision for the same file attachment")
    end
  end

  describe "#remove_file_attachment" do
    it "removes the attachment from the attachment revisions" do
      other_attachment_revision = create :file_attachment_revision
      revision = create :revision, file_attachment_revisions: [other_attachment_revision,
                                                               attachment_revision]

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_file_attachment(attachment_revision)

      next_revision = updater.next_revision
      expect(next_revision.file_attachment_revisions).to match_array [other_attachment_revision]
    end

    it "updates the ordering when there are featured attachments" do
      document_type = build :document_type, attachments: "featured"
      ordering = [attachment_revision.featured_attachment_id]

      revision = create :revision,
                        document_type: document_type,
                        file_attachment_revisions: [attachment_revision],
                        featured_attachment_ordering: ordering

      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.remove_file_attachment(attachment_revision)

      next_revision = updater.next_revision
      expect(next_revision.featured_attachment_ordering).to be_empty
    end
  end

  describe "#update_file_attachment" do
    it "updates an existing file attachment with a new revision" do
      updated_attachment = create :file_attachment_revision,
                                  file_attachment_id: attachment_revision.file_attachment_id

      revision = create :revision, file_attachment_revisions: [attachment_revision]
      updater = Versioning::RevisionUpdater.new(revision, user)
      updater.update_file_attachment(updated_attachment)

      next_revision = updater.next_revision
      expect(next_revision.file_attachment_revisions).to match_array [updated_attachment]
    end

    it "raises an error if there is no file attachment to update" do
      revision = create :revision
      updater = Versioning::RevisionUpdater.new(revision, user)

      expect { updater.update_file_attachment(attachment_revision) }
        .to raise_error(RuntimeError, "Cannot update a file attachment that doesn't exist")
    end
  end
end
