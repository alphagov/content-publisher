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
        summary: translation["summary"],
        associations: associations(edition),
      )

      doc.save!
    end

    def associations(edition)
      associations = {}
      associations["primary_publishing_organisation"] = primary_publishing_organisation(edition)
      associations["organisations"] = organisations(edition)
      associations["worldwide_organisations"] = edition["worldwide_organisations"]
      associations["topical_events"] = edition["topical_events"]
      associations["world_locations"] = edition["world_locations"]
      associations
    end

    def primary_publishing_organisation(edition)
      [lead_organisations(edition).shift]
    end

    def organisations(edition)
      organisations = edition["supporting_organisations"]
      organisations += lead_organisations(edition) if lead_organisations(edition).any?
      organisations
    end

    def lead_organisations(edition)
      edition["lead_organisations"]
    end
  end
end
