# frozen_string_literal: true

RSpec.describe EditionFilter do
  describe "#editions" do
    it "orders the editions by edition last_edited_at" do
      edition1 = create(:edition, last_edited_at: 1.minute.ago)
      edition2 = create(:edition, last_edited_at: 2.minutes.ago)

      editions = EditionFilter.new(sort: "last_updated").editions
      expect(editions).to eq([edition2, edition1])

      editions = EditionFilter.new(sort: "-last_updated").editions
      expect(editions).to eq([edition1, edition2])

      editions = EditionFilter.new(sort: "default -last_updated").editions
      expect(editions).to eq([edition1, edition2])
    end

    it "filters the editions by title or URL" do
      edition1 = create(:edition, title: "First", base_path: "/doc_1")
      edition2 = create(:edition, title: "Second", base_path: "/doc_2")

      editions = EditionFilter.new(filters: { title_or_url: " " }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(filters: { title_or_url: "Fir" }).editions
      expect(editions).to eq([edition1])

      editions = EditionFilter.new(filters: { title_or_url: "_1" }).editions
      expect(editions).to eq([edition1])

      editions = EditionFilter.new(filters: { title_or_url: "%" }).editions
      expect(editions).to be_empty
    end

    it "filters the editions by type" do
      edition1 = create(:edition, document_type_id: "type_1")
      edition2 = create(:edition, document_type_id: "type_2")

      editions = EditionFilter.new(filters: { document_type: " " }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(filters: { document_type: "type_1" }).editions
      expect(editions).to eq([edition1])
    end

    it "filters the editions by status" do
      edition1 = create(:edition, state: "draft")
      edition2 = create(:edition, state: "submitted_for_review")

      editions = EditionFilter.new(filters: { status: " " }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(filters: { status: "non-existant" }).editions
      expect(editions).to be_empty

      editions = EditionFilter.new(filters: { status: "draft" }).editions
      expect(editions).to eq([edition1])
    end

    it "includes published_but_needs_2i in published status filter" do
      edition1 = create(:edition, state: "published")
      edition2 = create(:edition, state: "published_but_needs_2i")

      editions = EditionFilter.new(filters: { status: "published" }).editions
      expect(editions).to match_array([edition1, edition2])

      editions = EditionFilter.new(filters: { status: "published_but_needs_2i" }).editions
      expect(editions).to eq([edition2])
    end

    it "filters the editions by organisation" do
      edition1 = create(:edition, tags: { primary_publishing_organisation: %w[org1] })
      edition2 = create(:edition, tags: { organisations: %w[org1] })
      edition3 = create(:edition, tags: { organisations: %w[org11] })

      editions = EditionFilter.new(filters: { organisation: " " }).editions
      expect(editions).to match_array([edition1, edition2, edition3])

      editions = EditionFilter.new(filters: { organisation: "org1" }).editions
      expect(editions).to match_array([edition1, edition2])
    end

    it "ignores other kinds of filter" do
      edition1 = create(:edition)

      editions = EditionFilter.new(filters: { invalid: "filter" }).editions
      expect(editions).to eq([edition1])
    end

    it "paginates the editions" do
      edition1 = create(:edition, last_edited_at: 1.minute.ago)
      edition2 = create(:edition, last_edited_at: 2.minutes.ago)

      editions = EditionFilter.new(page: 1, per_page: 1).editions
      expect(editions).to eq([edition1])

      editions = EditionFilter.new(page: 2, per_page: 1).editions
      expect(editions).to eq([edition2])
    end
  end
end
