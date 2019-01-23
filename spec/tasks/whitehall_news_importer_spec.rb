# frozen_string_literal: true

require "tasks/whitehall_news_importer"

RSpec.describe Tasks::WhitehallNewsImporter do
  let(:import_data) do
    {
      content_id: SecureRandom.uuid,
      editions: [
        {
          created_at: Time.current,
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
          minor_change: false,
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
    edition = Edition.last

    expect(edition.summary)
      .to eq(imported_edition["translations"][0]["summary"])
    expect(edition.tags["primary_publishing_organisation"])
      .to eq([imported_edition["lead_organisations"][0]])
    expect(edition.tags["organisations"]).to include(
      imported_edition["lead_organisations"][1],
      imported_edition["supporting_organisations"][0],
      imported_edition["supporting_organisations"][1],
    )
    expect(edition.tags["organisations"]).not_to include(
      imported_edition["lead_organisations"][0],
    )
    expect(edition.tags["worldwide_organisations"])
      .to eq(imported_edition["worldwide_organisations"])
    expect(edition.tags["topical_events"])
      .to eq(imported_edition["topical_events"])
    expect(edition.tags["world_locations"])
      .to eq(imported_edition["world_locations"])

    expect(edition.number).to eql(1)
    expect(edition.status).to be_draft
    expect(edition.update_type).to eq("major")
  end

  it "sets the correct states when Whitehall document state is 'published'" do
    import_data[:editions][0][:state] = "published"
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)

    expect(Edition.last.status).to be_published
    expect(Edition.last).to be_live
  end

  it "can set minor update type" do
    import_data[:editions][0][:minor_change] = true
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)
    expect(Edition.last.update_type).to eq("minor")
  end


  it "sets the correct states when Whitehall document is force published" do
    import_data[:editions][0][:state] = "published"
    import_data[:editions][0][:force_published] = true
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)

    expect(Edition.last.status).to be_published_but_needs_2i
    expect(Edition.last).to be_live
  end

  it "sets the correct states when Whitehall document state is 'rejected'" do
    import_data[:editions][0][:state] = "rejected"
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)

    expect(Edition.last.status).to be_submitted_for_review
    expect(Edition.last).not_to be_live
  end

  it "sets the correct states when Whitehall document state is 'submitted'" do
    import_data[:editions][0][:state] = "submitted"
    parsed_json = JSON.parse(import_data.to_json)
    Tasks::WhitehallNewsImporter.new.import(parsed_json)

    expect(Edition.last.status).to be_submitted_for_review
    expect(Edition.last).not_to be_live
  end

  it "skips importing documents with Whitheall states that are not supported" do
    import_data[:editions][0][:state] = "not_supported"
    parsed_json = JSON.parse(import_data.to_json)
    importer = Tasks::WhitehallNewsImporter.new
    expect { importer.import(parsed_json) }.not_to(change { Document.count })
  end

  it "changes the ids of embedded contacts" do
    import_data[:editions][0][:translations][0][:body] = "[Contact:123]"
    content_id = SecureRandom.uuid
    import_data[:contacts] = { "123" => content_id }
    Tasks::WhitehallNewsImporter.new.import(JSON.parse(import_data.to_json))

    expect(Edition.last.contents["body"]).to eq("[Contact:#{content_id}]")
  end

  context "when an imported document has more than one edition" do
    let(:import_published_then_drafted_data) do
      {
        content_id: SecureRandom.uuid,
        editions: [
          {
            created_at: Time.current,
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
          {
            created_at: Time.current - 1.day,
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
            state: "published",
            force_published: false,
          },
        ],
      }
    end


    it "only creates the latest edition" do
      parsed_json = JSON.parse(import_published_then_drafted_data.to_json)
      Tasks::WhitehallNewsImporter.new.import(parsed_json)

      expect(Edition.last.status).to be_draft
      expect(Edition.last).not_to be_live
    end
  end
end
