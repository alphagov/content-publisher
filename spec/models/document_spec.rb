# frozen_string_literal: true

RSpec.describe Document do
  describe ".create_initial" do
    let(:content_id) { SecureRandom.uuid }
    let(:document_type) { build(:document_type) }
    let(:user) { build(:user) }
    let(:doc) {
      Document.create_initial(
        content_id: content_id,
        document_type_id: document_type.id,
        user: user,
      )
    }

    it "creates a document with a current edition" do
      expect(doc).to be_a(Document)
      expect(doc.content_id).to eq(content_id)
      expect(doc.current_edition).to be_a(Edition)
      expect(doc.current_edition.created_by).to eq(user)
    end

    it "passes on the `document_type_id` to the relevant metadata_revision" do
      expect(doc.editions.first.revisions.first.metadata_revision.document_type_id).to eq(document_type.id)
    end
  end

  describe "#newly_created?" do
    it "returns false if there isn't a current edition" do
      document = create(:edition, current: false).document

      expect(document.newly_created?).to be false
    end

    it "returns false if the current edition isn't the first one" do
      document = create(:edition, current: true, number: 3).document

      expect(document.newly_created?).to be false
    end

    it "returns true if the timestamps are equal" do
      document = create(:edition, current: true, number: 1).document

      expect(document.newly_created?).to be true
    end
  end
end
