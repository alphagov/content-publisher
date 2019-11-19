# frozen_string_literal: true

class WhitehallImporter::CreateRevision
  attr_reader :document, :whitehall_edition, :translation

  SUPPORTED_DOCUMENT_TYPES = %w(news_story press_release).freeze
  DOCUMENT_SUB_TYPES = %w[
    news_article_type
    publication_type
    corporate_information_page_type
    speech_type
  ].freeze

  def initialize(document, whitehall_edition, translation)
    @document = document
    @whitehall_edition = whitehall_edition
    @translation = translation
  end

  def call
    document_type_key = DOCUMENT_SUB_TYPES.reject { |t| whitehall_edition[t].nil? }.first
    raise WhitehallImporter::AbortImportError, "Edition has an unsupported document type" unless SUPPORTED_DOCUMENT_TYPES.include?(whitehall_edition[document_type_key])

    Revision.create!(
      document: document,
      number: document.next_revision_number,
      imported: true,
      content_revision: ContentRevision.new(
        title: translation["title"],
        base_path: translation["base_path"],
        summary: translation["summary"],
        contents: {
          body: embed_contacts(translation["body"], whitehall_edition.fetch("contacts", [])),
        },
      ),
      metadata_revision: MetadataRevision.new(
        update_type: whitehall_edition["minor_change"] ? "minor" : "major",
        change_note: whitehall_edition["change_note"],
        document_type_id: whitehall_edition[document_type_key],
      ),
      tags_revision: TagsRevision.new(
        tags: {
          "primary_publishing_organisation" => primary_publishing_organisation(whitehall_edition["organisations"]),
          "organisations" => supporting_organisations(whitehall_edition["organisations"]),
          "role_appointments" => tags(whitehall_edition["role_appointments"]),
          "topical_events" => tags(whitehall_edition["topical_events"]),
          "world_locations" => tags(whitehall_edition["world_locations"]),
        },
      ),
      created_at: whitehall_edition["created_at"],
    )
  end

private

  def primary_publishing_organisation(organisations)
    unless organisations
      raise WhitehallImporter::AbortImportError, "Must have at least one organisation"
    end

    primary_publishing_organisations = organisations.select do |organisation|
      organisation["lead"]
    end

    unless primary_publishing_organisations.any?
      raise WhitehallImporter::AbortImportError, "Lead organisation missing"
    end

    if primary_publishing_organisations.count > 1
      raise WhitehallImporter::AbortImportError, "Cannot have more than one lead organisation"
    end

    primary_publishing_organisation = primary_publishing_organisations.min { |o| o["lead_ordering"] }

    [primary_publishing_organisation["content_id"]]
  end

  def supporting_organisations(organisations)
    supporting_organisations = organisations.reject do |organisation|
      organisation["lead"]
    end

    supporting_organisations.map { |organisation| organisation["content_id"] }
  end

  def tags(associations)
    return [] unless associations

    associations.map { |association| association["content_id"] }
  end

  def embed_contacts(body, contacts)
    body&.gsub(/\[Contact:\s*(\d*)\s*\]/) do
      id = Regexp.last_match[1].to_i
      embed = contacts.select { |x| x["id"] == id }.first["content_id"]
      "[Contact:#{embed}]"
    end
  end
end
