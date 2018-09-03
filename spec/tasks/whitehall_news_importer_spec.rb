# frozen_string_literal: true

require "tasks/whitehall_news_importer"

RSpec.describe Tasks::WhitehallNewsImporter do
  it "can import JSON data from Whitehall" do
    import_json = {
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
        },
      ],
    }.to_json

    importer = Tasks::WhitehallNewsImporter.new
    parsed_json = JSON.parse(import_json)

    expect { importer.import(parsed_json) }.to change { Document.count }.by(1)
    expect(Document.last.summary).to eq(
      parsed_json["editions"][0]["translations"][0]["summary"]
    )
    expect(Document.last.associations["primary_publishing_organisation"][0])
      .to eq(parsed_json["editions"][0]["lead_organisations"][0])
  end
end
