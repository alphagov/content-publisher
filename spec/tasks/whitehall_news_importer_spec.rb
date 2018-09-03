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
        },
      ],
    }.to_json

    importer = Tasks::WhitehallNewsImporter.new

    expect { importer.import(JSON.parse(import_json)) }
      .to change { Document.count }.by(1)
  end
end
