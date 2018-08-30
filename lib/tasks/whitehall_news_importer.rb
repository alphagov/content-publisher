# frozen_string_literal: true

module Tasks
  class WhitehallNewsImporter
    def initialize(to_import)
      @to_import = to_import
    end

    def import
      to_import.each do |document|
        edition = most_recent_edition(document)
        edition["translations"].each do |translation|
          create_document(translation, edition, document)
        end
      end
      to_import.count
    end

  private

    attr_reader :to_import

    def most_recent_edition(document)
      document["editions"].max_by { |e| e["created_at"] }
    end

    def create_document(translation, edition, document)
      Document.create!(
        base_path: "/government/news/#{document['slug']}",
        content_id: document["content_id"],
        contents: {
          body: translation["body"],
        },
        document_type: edition["news_article_type"]["key"],
        locale: translation["locale"],
        title: translation["title"],
        publication_state: "changes_not_sent_to_draft",
      )
    end
  end
end
