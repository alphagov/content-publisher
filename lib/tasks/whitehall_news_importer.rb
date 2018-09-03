# frozen_string_literal: true

module Tasks
  class WhitehallNewsImporter
    def import(document)
      edition = most_recent_edition(document)

      edition["translations"].each do |translation|
        create_or_update_document(translation, edition, document)
      end
    end

  private

    attr_reader :to_import

    def most_recent_edition(document)
      document["editions"].max_by { |e| e["created_at"] }
    end

    def create_or_update_document(translation, edition, document)
      doc = Document.find_or_initialize_by(content_id: document["content_id"],
                                           locale: translation["locale"])

      doc.assign_attributes(
        base_path: translation["base_path"],
        contents: {
          body: translation["body"],
        },
        document_type: edition["news_article_type"]["key"],
        title: translation["title"],
        publication_state: "changes_not_sent_to_draft",
      )

      doc.save!
    end
  end
end
