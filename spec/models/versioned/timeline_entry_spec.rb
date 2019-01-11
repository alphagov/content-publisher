# frozen_string_literal: true

RSpec.describe Versioned::TimelineEntry do
  describe ".created_for_status_change" do
    let(:edition) { build(:versioned_edition) }

    it "creates a TimelineEntry" do
      status = build(:versioned_status,
                     state: :submitted_for_review,
                     edition: edition)

      entry = Versioned::TimelineEntry.create_for_status_change(
        entry_type: :submitted,
        status: status,
      )

      expect(entry).to be_a(Versioned::TimelineEntry)
      expect(entry).not_to be_new_record
      expect(entry).to be_submitted
      expect(entry.status).to eq(status)
    end

    it "sets the created_by, edition and document based on status" do
      status = build(:versioned_status,
                     state: :submitted_for_review,
                     edition: edition)

      entry = Versioned::TimelineEntry.create_for_status_change(
        entry_type: :submitted,
        status: status,
      )

      expect(entry.created_by).to eq(status.created_by)
      expect(entry.edition).to eq(status.edition)
      expect(entry.document).to eq(status.edition.document)
    end
  end

  describe ".created_for_revision" do
    let(:edition) { build(:versioned_edition) }

    it "creates a TimelineEntry" do
      revision = build(:versioned_revision, document: edition.document)

      entry = Versioned::TimelineEntry.create_for_revision(
        entry_type: :updated_content,
        edition: edition,
        revision: revision,
      )

      expect(entry).to be_a(Versioned::TimelineEntry)
      expect(entry).not_to be_new_record
      expect(entry).to be_updated_content
      expect(entry.revision).to eq(revision)
    end

    it "can set the revision based on the edition" do
      entry = Versioned::TimelineEntry.create_for_revision(
        entry_type: :submitted,
        edition: edition,
      )

      expect(entry.revision).to eq(edition.revision)
      expect(entry.edition).to eq(edition)
    end
  end
end
