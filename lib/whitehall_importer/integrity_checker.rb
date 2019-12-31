# frozen_string_literal: true

module WhitehallImporter
  class IntegrityChecker
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def valid?
      problems.empty?
    end

    def problems
      content_problems + image_problems + organisation_problems
    end

  private

    def content_problems
      problems = []

      %w(base_path
         title
         description
         document_type
         schema_name).each do |attribute|
        if publishing_api_content[attribute] != proposed_payload[attribute]
          problems << "#{attribute} doesn't match"
        end
      end

      problems << "body text doesn't match" unless body_text_matches?

      problems
    end

    def body_text_matches?
      proposed_body_text = proposed_payload.dig("details", "body")
      publishing_api_body_text = publishing_api_content.dig("details", "body")

      Sanitize.clean(publishing_api_body_text).squish == Sanitize.clean(proposed_body_text).squish
    end

    def image_problems
      proposed_image_payload = proposed_payload.dig("details", "image") || {}
      publishing_api_image = publishing_api_content.dig("details", "image") || {}

      %w(alt_text caption).each_with_object([]) do |attribute, problems|
        if publishing_api_image[attribute] != proposed_image_payload[attribute]
          problems << "image #{attribute} doesn't match"
        end
      end
    end

    def organisation_problems
      problems = []
      problems << "primary_publishing_organisation doesn't match" unless primary_publishing_organisation_matches?

      problems
    end

    def primary_publishing_organisation_matches?
      proposed_payload.dig("links", "primary_publishing_organisation") == publishing_api_content.dig("links", "primary_publishing_organisation")
    end

    def proposed_payload
      @proposed_payload ||= PreviewService::Payload.new(edition, republish: edition.live?).payload
    end

    def publishing_api_content
      @publishing_api_content ||= GdsApi.publishing_api.get_content(edition.content_id).to_h
    end
  end
end
