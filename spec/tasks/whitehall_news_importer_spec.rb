# frozen_string_literal: true

require "spec_helper"
require "tasks/whitehall_news_importer"

RSpec.describe Tasks::WhitehallNewsImporter do
  it "can import JSON data from Whitehall" do
    import_json = [
      {
        content_id: SecureRandom.uuid,
        slug: "test-page",
        editions: [
          {
            created_at: Time.zone.now,
            news_article_type: { key: "news_story" },
            translations: [
              { locale: "en", title: "Title", summary: "Summary", body: "Body" }
            ]
          }
        ]
      }
    ].to_json

    expect { Tasks::WhitehallNewsImporter.new(JSON.parse(import_json)).import }
      .to change { Document.count }.by(1)
  end
end
