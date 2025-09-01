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

    it "has a `tags` property" do
      tags = { "primary_publishing_organisation" => [SecureRandom.uuid] }
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, document:, tags:)

      expect(described_class.export_to_hash(document)[:tags]).to eq(tags)
    end

    it "has a `political` property" do
      document = build(:document, :live)
      document.live_edition = create(:edition, :published, document:)
      allow(document.live_edition).to receive(:political?).and_return(true)

      expect(described_class.export_to_hash(document)[:political]).to be(true)
    end

    describe "the `document_history` property" do
      let(:document) { instance_double(Document) }

      it "includes internal notes" do
        details = instance_double(InternalNote, body: "This is an internal note")
        e = entry_double(
          internal_note?: true,
          details:,
          entry_type: "internal_note",
          edition: instance_double(Edition, number: 1),
          created_by: instance_double(User, email: "example@gov.uk"),
        )
        stub_chain_with([e])

        expect(described_class.document_history(document)).to eq([
          {
            edition_number: 1,
            entry_type: "internal_note",
            date: "2024-01-01",
            time: "10:00",
            backdated_to: nil,
            user: "example@gov.uk",
            entry_content: "This is an internal note",
          },
        ])
      end

      it "includes withdrawn/updated entries with public explanation" do
        details = instance_double(Withdrawal, public_explanation: "Withdrawn explanation")
        e = entry_double(
          withdrawn_updated?: true,
          details:,
          entry_type: "withdrawn",
          edition: instance_double(Edition, number: 2),
          created_at: build_time(date: "2024-02-01", time: "11:00"),
          created_by: instance_double(User, email: "withdrawn-author@gov.uk"),
        )
        stub_chain_with([e])

        expect(described_class.document_history(document)).to eq([
          {
            edition_number: 2,
            entry_type: "withdrawn",
            date: "2024-02-01",
            time: "11:00",
            backdated_to: nil,
            user: "withdrawn-author@gov.uk",
            entry_content: "Withdrawn explanation",
          },
        ])
      end

      it "includes backdated entries (backdated_to on revision) with nil entry_content" do
        backdated_to = Date.new(2022, 1, 1) # real Date; .to_fs(:date) -> "2022-01-01"
        revision = instance_double(Revision, backdated_to:)

        e = entry_double(
          backdated?: true,
          revision:,
          entry_type: "published",
          edition: instance_double(Edition, number: 5),
          created_at: build_time(date: "2024-05-01", time: "14:00"),
          created_by: instance_double(User, email: "backdated-author@gov.uk"),
        )
        stub_chain_with([e])

        expect(described_class.document_history(document)).to eq([
          {
            edition_number: 5,
            entry_type: "published",
            date: "2024-05-01",
            time: "14:00",
            backdated_to: "2022-01-01",
            user: "backdated-author@gov.uk",
            entry_content: nil,
          },
        ])
      end

      it "returns entries ordered by created_at desc (we respect the chain's order)" do
        newer = entry_double(
          entry_type: "withdrawn",
          withdrawn_updated?: true,
          details: instance_double(Withdrawal, public_explanation: "Later"),
          edition: instance_double(Edition, number: 2),
          created_at: build_time(date: "2024-02-01", time: "11:00"),
          created_by: instance_double(User, email: "b@gov.uk"),
        )

        older = entry_double(
          internal_note?: true,
          details: instance_double(InternalNote, body: "Earlier note"),
          entry_type: "internal_note",
          edition: instance_double(Edition, number: 1),
          created_at: build_time(date: "2024-01-01", time: "10:00"),
          created_by: instance_double(User, email: "a@gov.uk"),
        )

        # We hand back [newer, older] from the ordered chain
        stub_chain_with([newer, older])

        result = described_class.document_history(document)
        expect(result.map { |h| h[:edition_number] }).to eq([2, 1])
      end

      def build_time(date:, time:)
        t = instance_double(Time)
        allow(t).to receive(:to_fs).with(:date).and_return(date)
        allow(t).to receive(:to_fs).with(:time).and_return(time)
        t
      end

      def stub_chain_with(entries)
        # Simulate: TimelineEntry.where(document: doc).includes(...).order(...).includes(...)
        allow(TimelineEntry).to receive(:where).with(document:).and_return(entries)
        allow(entries).to receive(:includes).and_return(entries)
        allow(entries).to receive(:order).with(created_at: :desc).and_return(entries)
      end

      def entry_double(overrides = {})
        defaults = {
          edition: instance_double(Edition, number: 1),
          entry_type: "internal_note",
          created_at: build_time(date: "2024-01-01", time: "10:00"),
          created_by: instance_double(User, email: "example@gov.uk"),
          details: nil,
          internal_note?: false,
          withdrawn?: false,
          withdrawn_updated?: false,
          backdated?: false,
          revision: nil,
        }
        instance_double(TimelineEntry, **defaults.merge(overrides))
      end
    end
  end
end
