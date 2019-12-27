# frozen_string_literal: true

require "damerau-levenshtein"

class PublishingApiComparisionService < ApplicationService
  attr_reader :edition, :published

  def initialize(edition, published: false)
    @edition = edition
    @published = published
  end

  def call
    proposed_edition = PreviewService::Payload.new(edition, republish: published).payload
    edition_in_publishing_api = GdsApi.publishing_api.get_content(edition.content_id).to_h

    if published
      version = edition_in_publishing_api["state_history"].select { |_, hash| hash["published"] }
      published_version = version.keys.first.to_i

      edition_in_publishing_api = GdsApi.publishing_api.get_content(edition.content_id, version: published_version).to_h
    end

    raise WhitehallImporter::AbortImportError, "Versions don't match" unless versions_match?(edition_in_publishing_api, proposed_edition)
    raise WhitehallImporter::AbortImportError, "Links don't match" unless links_match?(content_id, proposed_edition)
  end

private

  def versions_match?(edition_in_publishing_api, proposed_edition)
    edition_in_publishing_api["base_path"] == proposed_edition["base_path"] &&
      edition_in_publishing_api["title"] == proposed_edition["title"] &&
      edition_in_publishing_api["description"] == proposed_edition["description"] &&
      edition_in_publishing_api["first_published_at"] == proposed_edition["first_published_at"] &&
      edition_in_publishing_api["public_updated_at"] == proposed_edition["public_updated_at"] &&
      edition_in_publishing_api["document_type"]["id"] == proposed_edition["document_type"] &&
      edition_in_publishing_api["schema_name"] == proposed_edition["schema_name"] &&
      details_match?(edition_in_publishing_api["details"], proposed_edition["details"])
  end

  def details_match?(pub_api_details, proposed_details)
    body_text_similar_enough?(pub_api_details["body"], proposed_details["body"]) &&
    images_match?()
  end

  def body_text_similar_enough?(pub_api_body, proposed_body)
    # See https://www.rubydoc.info/gems/damerau-levenshtein/1.1.0#API_Description
    DamerauLevenshtein.distance(pub_api_body, proposed_body, 1, 100) < 100
  end

  def links_match?(content_id, proposed_edition)
    links_in_publishing_api = GdsApi.publishing_api.get_links(content_id).to_h
    proposed_links = proposed_edition["links"]

    links_in_publishing_api["government"].sort == proposed_links["government"].sort &&
      links_in_publishing_api["organisations"].sort == proposed_links["organisations"].sort &&
      links_in_publishing_api["taxons"].sort == proposed_links["taxons"].sort &&
      links_in_publishing_api["primary_publishing_organisation"] == proposed_links["primary_publishing_organisation"]
  end
end
