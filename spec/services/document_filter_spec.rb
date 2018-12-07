# frozen_string_literal: true

RSpec.describe DocumentFilter do
  describe "#documents" do
    it "orders the documents by updated_at" do
      document1 = create(:document, updated_at: 1.minute.ago)
      document2 = create(:document, updated_at: 2.minutes.ago)

      documents = DocumentFilter.new(sort: "updated_at").documents
      expect(documents).to eq([document2, document1])

      documents = DocumentFilter.new(sort: "-updated_at").documents
      expect(documents).to eq([document1, document2])

      documents = DocumentFilter.new(sort: "default -updated_at").documents
      expect(documents).to eq([document1, document2])
    end

    it "filters the documents by title or URL" do
      document1 = create(:document, title: "First", base_path: "/doc_1")
      document2 = create(:document, title: "Second", base_path: "/doc_2")

      documents = DocumentFilter.new(filters: { title_or_url: " " }).documents
      expect(documents).to match_array([document1, document2])

      documents = DocumentFilter.new(filters: { title_or_url: "Fir" }).documents
      expect(documents).to eq([document1])

      documents = DocumentFilter.new(filters: { title_or_url: "_1" }).documents
      expect(documents).to eq([document1])

      documents = DocumentFilter.new(filters: { title_or_url: "%" }).documents
      expect(documents).to be_empty
    end

    it "filters the documents by type" do
      document1 = create(:document, document_type_id: "type_1")
      document2 = create(:document, document_type_id: "type_2")

      documents = DocumentFilter.new(filters: { document_type: " " }).documents
      expect(documents).to match_array([document1, document2])

      documents = DocumentFilter.new(filters: { document_type: "type_1" }).documents
      expect(documents).to eq([document1])
    end

    it "filters the documents by state" do
      document1 = create(:document, publication_state: "sent_to_draft")
      document2 = create(:document, publication_state: "sent_to_live")

      documents = DocumentFilter.new(filters: { state: " " }).documents
      expect(documents).to match_array([document1, document2])

      documents = DocumentFilter.new(filters: { state: "non-existant" }).documents
      expect(documents).to be_empty

      documents = DocumentFilter.new(filters: { state: "draft" }).documents
      expect(documents).to eq([document1])
    end

    it "filters the documents by organisation" do
      document1 = create(:document, tags: { primary_publishing_organisation: %w[org1] })
      document2 = create(:document, tags: { organisations: %w[org1] })
      document3 = create(:document, tags: { organisations: %w[org11] })

      documents = DocumentFilter.new(filters: { organisation: " " }).documents
      expect(documents).to match_array([document1, document2, document3])

      documents = DocumentFilter.new(filters: { organisation: "org1" }).documents
      expect(documents).to match_array([document1, document2])
    end

    it "ignores other kinds of filter" do
      document1 = create(:document)

      documents = DocumentFilter.new(filters: { invalid: "filter" }).documents
      expect(documents).to eq([document1])
    end

    it "paginates the documents" do
      document1 = create(:document, updated_at: 1.minute.ago)
      document2 = create(:document, updated_at: 2.minutes.ago)

      documents = DocumentFilter.new(page: 1, per_page: 1).documents
      expect(documents).to eq([document1])

      documents = DocumentFilter.new(page: 2, per_page: 1).documents
      expect(documents).to eq([document2])
    end
  end
end
