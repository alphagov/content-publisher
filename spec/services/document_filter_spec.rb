# frozen_string_literal: true

RSpec.describe DocumentFilter do
  describe "#documents" do
    it "orders the documents by updated_at" do
      document_1 = create(:document, updated_at: 1.minute.ago)
      document_2 = create(:document, updated_at: 2.minutes.ago)

      documents = DocumentFilter.new(sort: "updated_at").documents
      expect(documents).to eq([document_2, document_1])

      documents = DocumentFilter.new(sort: "-updated_at").documents
      expect(documents).to eq([document_1, document_2])

      documents = DocumentFilter.new(sort: "default -updated_at").documents
      expect(documents).to eq([document_1, document_2])
    end

    it "filters the documents by title or URL" do
      document_1 = create(:document, title: "First", base_path: "/doc_1")
      document_2 = create(:document, title: "Second", base_path: "/doc_2")

      documents = DocumentFilter.new(filters: { title_or_url: " " }).documents
      expect(documents).to match_array([document_1, document_2])

      documents = DocumentFilter.new(filters: { title_or_url: "Fir" }).documents
      expect(documents).to eq([document_1])

      documents = DocumentFilter.new(filters: { title_or_url: "_1" }).documents
      expect(documents).to eq([document_1])
    end

    it "filters the documents by type" do
      document_1 = create(:document, document_type: "type_1")
      document_2 = create(:document, document_type: "type_2")

      documents = DocumentFilter.new(filters: { document_type: " " }).documents
      expect(documents).to match_array([document_1, document_2])

      documents = DocumentFilter.new(filters: { document_type: "type_1" }).documents
      expect(documents).to eq([document_1])
    end

    it "ignores other kinds of filter" do
      document_1 = create(:document)

      documents = DocumentFilter.new(filters: { invalid: "filter" }).documents
      expect(documents).to eq([document_1])
    end

    it "paginates the documents" do
      document_1 = create(:document, updated_at: 1.minute.ago)
      document_2 = create(:document, updated_at: 2.minutes.ago)

      documents = DocumentFilter.new(page: 1, per_page: 1).documents
      expect(documents).to eq([document_1])

      documents = DocumentFilter.new(page: 2, per_page: 1).documents
      expect(documents).to eq([document_2])
    end
  end
end
