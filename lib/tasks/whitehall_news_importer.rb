# frozen_string_literal: true

module Tasks
  class WhitehallNewsImporter
    SUPPORTED_WHITEHALL_STATES = %w(draft published rejected submitted).freeze

    def import(document)
      edition = most_recent_edition(document)

      edition["translations"].each do |translation|
        next unless SUPPORTED_WHITEHALL_STATES.include?(edition["state"])

        create_or_update_document(translation, edition, document)
      end
    end

  private

    def most_recent_edition(document)
      document["editions"].max_by { |e| e["created_at"] }
    end

    def create_or_update_document(translation, whitehall_edition, whitehall_document)
      document = Document.find_or_initialize_by(
        content_id: whitehall_document["content_id"],
        locale: translation["locale"],
        document_type_id: whitehall_edition["news_article_type"]["key"],
      )

      revision = Revision.new(
        document: document,
        number: document.next_revision_number,
        content_revision: ContentRevision.new(
          title: translation["title"],
          base_path: translation["base_path"],
          summary: translation["summary"],
          contents: {
            body: embed_contacts(translation["body"], whitehall_document.fetch("contacts", {})),
          },
        ),
        metadata_revision: MetadataRevision.new(
          update_type: whitehall_edition["minor_change"] ? "minor" : "major",
        ),
        tags_revision: TagsRevision.new(tags: tags(whitehall_edition)),
      )

      edition = Edition.new(
        document: document,
        number: whitehall_document["editions"].count,
        revision_synced: true,
        revision: revision,
        status: Status.new(
          state: state(whitehall_edition),
          revision_at_creation: revision,
        ),
        current: true,
        live: live?(whitehall_edition),
      )

      edition.save!
    end

    def tags(whitehall_edition)
      tags = {}
      tags["primary_publishing_organisation"] = primary_publishing_organisation(whitehall_edition)
      tags["organisations"] = organisations(whitehall_edition)
      tags["worldwide_organisations"] = whitehall_edition["worldwide_organisations"]
      tags["topical_events"] = whitehall_edition["topical_events"]
      tags["world_locations"] = whitehall_edition["world_locations"]
      tags
    end

    def primary_publishing_organisation(whitehall_edition)
      [lead_organisations(whitehall_edition).shift]
    end

    def organisations(whitehall_edition)
      organisations = whitehall_edition["supporting_organisations"]
      organisations += lead_organisations(whitehall_edition) if lead_organisations(whitehall_edition).any?
      organisations
    end

    def lead_organisations(whitehall_edition)
      whitehall_edition["lead_organisations"]
    end

    def state(whitehall_edition)
      case whitehall_edition["state"]
      when "draft" then "draft"
      when "published"
        whitehall_edition["force_published"] ? "published_but_needs_2i" : "published"
      else
        "submitted_for_review"
      end
    end

    def live?(whitehall_edition)
      whitehall_edition["state"] == "published"
    end

    def embed_contacts(body, contacts)
      body&.gsub(/\[Contact:\s*(\d*)\s*\]/) do
        id = Regexp.last_match[1]
        embed = contacts[id] || id
        "[Contact:#{embed}]"
      end
    end
  end
end
