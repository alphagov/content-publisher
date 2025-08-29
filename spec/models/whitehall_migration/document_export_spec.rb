RSpec.describe WhitehallMigration::DocumentExport do
  describe ".exportable_documents" do
    it "returns documents that are published (with or without 2i), or withdrawn" do
      Document.find_each(&:destroy) # Clean slate

      withdrawn_edition = create(:edition, :withdrawn)
      live_but_needs_2i = create(:edition, :published_but_needs_2i)
      documents_to_be_processed = [
        create(:document, :with_live_edition),
        create(:document, :with_current_and_live_editions),
        live_but_needs_2i.document,
        withdrawn_edition.document,
      ]

      # documents to be ignored
      create(:document, :with_current_edition)
      create(:edition, state: "submitted_for_review")
      create(:edition, :removed, removal: create(:removal, redirect: true, alternative_url: "/somewhere"))

      expect(described_class.exportable_documents.sort_by(&:id)).to eq(documents_to_be_processed.sort_by(&:id))
    end
  end

  describe "#export_to_hash" do
    it "takes a Document and maps it to a hash" do
      document = create(:document, :with_live_edition)
      expect(described_class.export_to_hash(document)).to be_a(Hash)
    end

    it "has a `content_id` property" do
      document = create(:document, :with_live_edition)
      expect(described_class.export_to_hash(document)[:content_id]).to eq(document.content_id)
    end

    it "has a `state` property" do
      document = create(:document, :with_live_edition)
      expect(described_class.export_to_hash(document)[:state]).to eq("published")
    end

    it "has a `created_at` property" do
      document = create(:document, :with_live_edition)
      expect(described_class.export_to_hash(document)[:created_at]).to eq(document.created_at)
    end

    it "has a `first_published_at` property" do
      document = create(:document, :with_live_edition)
      expect(described_class.export_to_hash(document)[:first_published_at]).to eq(document.first_published_at)
    end

    it "has a `updated_at` property" do
      document = create(:document, :with_live_edition)
      expect(described_class.export_to_hash(document)[:updated_at]).to eq(document.updated_at)
    end

    it "has a `created_by` property" do
      email = "foo@example.com"
      document = create(:document, :with_live_edition, created_by: build(:user, email:))
      expect(described_class.export_to_hash(document)[:created_by]).to eq(email)
    end

    it "has a `last_edited_by` property" do
      email = "foo@example.com"
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, created_by: build(:user, email:), document:)
      expect(described_class.export_to_hash(document)[:last_edited_by]).to eq(email)
    end

    it "has a `document_type` property" do
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, document_type: DocumentType.find("news_story"), document:)
      expect(described_class.export_to_hash(document)[:document_type]).to eq("news_story")
    end

    it "has a `title` property" do
      title = "Here is a title"
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, title:, document:)
      expect(described_class.export_to_hash(document)[:title]).to eq(title)
    end

    it "has a `base_path` property" do
      base_path = "/foo/bar"
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, base_path:, document:)
      expect(described_class.export_to_hash(document)[:base_path]).to eq(base_path)
    end

    it "has a `summary` property" do
      summary = "Here is a summary"
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, summary:, document:)
      expect(described_class.export_to_hash(document)[:summary]).to eq(summary)
    end

    it "has a `body` property" do
      body = <<~GOVSPEAK
        Here are some contents

        And here are some more!
      GOVSPEAK
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, document:, contents: { "body" => body })
      expect(described_class.export_to_hash(document)[:body]).to eq(body)
    end
  end
end
