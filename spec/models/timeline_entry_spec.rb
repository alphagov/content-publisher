RSpec.describe TimelineEntry do
  describe ".entry_types" do
    described_class.entry_types.each_key do |type|
      it "has a translation for `#{type}`" do
        expect(I18n.exists?("documents.history.entry_types.#{type}")).to be true
      end
    end
  end

  describe ".created_for_status_change" do
    let(:edition) { build(:edition) }

    it "creates a TimelineEntry" do
      status = build(:status,
                     state: :submitted_for_review,
                     edition:)

      entry = described_class.create_for_status_change(
        entry_type: :submitted,
        status:,
      )

      expect(entry).to be_a(described_class)
      expect(entry).not_to be_new_record
      expect(entry).to be_submitted
      expect(entry.status).to eq(status)
    end

    it "sets the created_by, edition and document based on status" do
      status = build(:status,
                     state: :submitted_for_review,
                     edition:)

      entry = described_class.create_for_status_change(
        entry_type: :submitted,
        status:,
      )

      expect(entry.created_by).to eq(status.created_by)
      expect(entry.edition).to eq(status.edition)
      expect(entry.document).to eq(status.edition.document)
    end
  end

  describe ".created_for_revision" do
    let(:edition) { create(:edition) }

    it "creates a TimelineEntry" do
      revision = create(:revision, document: edition.document)

      entry = described_class.create_for_revision(
        entry_type: :updated_content,
        edition:,
        revision:,
      )

      expect(entry).to be_a(described_class)
      expect(entry).not_to be_new_record
      expect(entry).to be_updated_content
      expect(entry.revision).to eq(revision)
    end

    it "can set the revision based on the edition" do
      entry = described_class.create_for_revision(
        entry_type: :submitted,
        edition:,
      )

      expect(entry.revision).to eq(edition.revision)
      expect(entry.edition).to eq(edition)
    end
  end
end
