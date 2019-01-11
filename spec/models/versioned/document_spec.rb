# frozen_string_literal: true

RSpec.describe Versioned::Document do
  describe ".create_initial" do
    it "creates a document with a current edition" do
      content_id = SecureRandom.uuid
      document_type = build(:document_type)
      user = build(:user)

      doc = Versioned::Document.create_initial(
        content_id: content_id,
        document_type_id: document_type.id,
        user: user,
      )

      expect(doc).to be_a(Versioned::Document)
      expect(doc.content_id).to eq(content_id)
      expect(doc.current_edition).to be_a(Versioned::Edition)
      expect(doc.current_edition.created_by).to eq(user)
    end
  end

  describe "#newly_created?" do
    it "returns false if there isn't a current edition" do
      document = create(:versioned_edition, current: false).document

      expect(document.newly_created?).to be false
    end

    it "returns false if the current edition isn't the first one" do
      document = create(:versioned_edition, current: true, number: 3).document

      expect(document.newly_created?).to be false
    end

    it "returns true if the timestamps are equal" do
      time = Time.current
      document = create(:versioned_edition,
                        current: true,
                        number: 1,
                        created_at: time,
                        updated_at: time).document

      expect(document.newly_created?).to be true
    end
  end
end
