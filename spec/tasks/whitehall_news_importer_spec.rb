# frozen_string_literal: true

require "tasks/whitehall_news_importer"

RSpec.describe Tasks::WhitehallNewsImporter do
  let(:import_data) do
    {
      content_id: SecureRandom.uuid,
      editions: [
        {
          created_at: Time.zone.now,
          news_article_type: { key: "news_story" },
          translations: [
            {
              locale: "en",
              title: "Title",
              summary: "Summary",
              body: "Body",
              base_path: "/government/news/title",
            },
          ],
          lead_organisations: [SecureRandom.uuid, SecureRandom.uuid],
          supporting_organisations: [SecureRandom.uuid, SecureRandom.uuid],
          worldwide_organisations: [SecureRandom.uuid, SecureRandom.uuid],
          topical_events: [SecureRandom.uuid, SecureRandom.uuid],
          world_locations: [SecureRandom.uuid, SecureRandom.uuid],
          state: "draft",
          force_published: false,
        },
      ],
    }
  end

  it "can import JSON data from Whitehall" do
    importer = Tasks::WhitehallNewsImporter.new
    parsed_json = JSON.parse(import_data.to_json)

    expect { importer.import(parsed_json) }.to change { Document.count }.by(1)

    imported_edition = JSON.parse(import_data.to_json)["editions"][0]
    document_tags = Document.last.tags

    expect(Document.last.summary)
      .to eq(imported_edition["translations"][0]["summary"])
    expect(document_tags["primary_publishing_organisation"])
      .to eq([imported_edition["lead_organisations"][0]])
    expect(document_tags["organisations"]).to include(
      imported_edition["lead_organisations"][1],
      imported_edition["supporting_organisations"][0],
      imported_edition["supporting_organisations"][1],
    )
    expect(document_tags["organisations"]).not_to include(
      imported_edition["lead_organisations"][0],
    )
    expect(document_tags["worldwide_organisations"])
      .to eq(imported_edition["worldwide_organisations"])
    expect(document_tags["topical_events"])
      .to eq(imported_edition["topical_events"])
    expect(document_tags["world_locations"])
      .to eq(imported_edition["world_locations"])

    expect(Document.last.current_edition_number).to eql(1)

    expect(Document.last.publication_state).to eq("sent_to_draft")
    expect(Document.last.review_state).to eq("unreviewed")
  end

  it "sets the correct publication state and review state when Whitehall document state is 'published'" do
    import_data[:editions][0][:state] = "published"
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)

    expect(Document.last.publication_state).to eq("sent_to_live")
    expect(Document.last.review_state).to eq("reviewed")
  end

  it "sets the correct publication state and review state when Whitehall document is force published" do
    import_data[:editions][0][:state] = "published"
    import_data[:editions][0][:force_published] = true
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)

    expect(Document.last.publication_state).to eq("sent_to_live")
    expect(Document.last.review_state).to eq("published_without_review")
  end
end
