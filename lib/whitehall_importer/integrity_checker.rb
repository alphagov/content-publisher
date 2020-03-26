module WhitehallImporter
  class IntegrityChecker
    attr_reader :edition

    def self.time_matches?(proposed_time, publishing_api_time, seconds_difference = 5)
      return true if proposed_time == publishing_api_time

      proposed_time = Time.zone.rfc3339(proposed_time)
      publishing_api_time = Time.zone.rfc3339(publishing_api_time)

      proposed_time.between?(publishing_api_time - seconds_difference,
                             publishing_api_time + seconds_difference)
    rescue ArgumentError
      false
    end

    def initialize(edition)
      @edition = edition
    end

    def valid?
      problems.empty?
    end

    def problems
      content_problems + image_problems + organisation_problems +
        time_problems + state_problems + unpublishing_problems
    end

    def proposed_payload
      @proposed_payload ||= PublishingApiPayload.new(edition, republish: edition.live?)
                                                .payload
                                                .as_json
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
          problems << problem_description(
            "#{attribute} doesn't match",
            publishing_api_content[attribute],
            proposed_payload[attribute],
          )
        end
      end

      problems << "body text doesn't match" unless BodyTextCheck.new(
        proposed_payload.dig("details", "body"),
        publishing_api_content.dig("details", "body"),
      ).sufficiently_similar?

      problems << "change history doesn't match" unless ChangeHistoryCheck.new(
        edition,
        proposed_payload.dig("details", "change_history"),
        publishing_api_content["details"].fetch("change_history", []),
      ).match?

      problems
    end

    def time_problems
      problems = []

      proposed_first_published_at = proposed_payload["first_published_at"]
      first_public_at = publishing_api_content["details"]["first_public_at"]

      unless time_matches?(proposed_first_published_at, first_public_at)
        problems << problem_description("our first_published_at doesn't match first_public_at",
                                        first_public_at,
                                        proposed_first_published_at)
      end

      proposed_public_updated_at = proposed_payload["public_updated_at"]
      public_updated_at = publishing_api_content["public_updated_at"]

      if edition.live? && !time_matches?(proposed_public_updated_at, public_updated_at)
        problems << problem_description("public_updated_at doesn't match",
                                        public_updated_at,
                                        proposed_public_updated_at)
      end

      problems
    end

    def time_matches?(proposed_time, publishing_api_time, seconds_difference = 60)
      self.class.time_matches?(proposed_time, publishing_api_time, seconds_difference)
    end

    def state_problems
      problems = []

      unless publishing_api_content["publication_state"] == expected_state
        problems << problem_description("publication_state isn't as expected",
                                        publishing_api_content["publication_state"],
                                        expected_state)
      end

      problems
    end

    def expected_state
      if %w[removed withdrawn].include?(edition.state)
        "unpublished"
      elsif %w[published published_but_needs_2i].include?(edition.state)
        "published"
      elsif %w[scheduled submitted_for_review draft].include?(edition.state)
        "draft"
      else
        "superseded"
      end
    end

    def image_problems
      proposed_image_payload = proposed_payload.dig("details", "image") || {}
      publishing_api_image = publishing_api_content.dig("details", "image") || {}

      %w(alt_text caption).each_with_object([]) do |attribute, problems|
        if publishing_api_image[attribute] != proposed_image_payload[attribute]
          next if default_image?(proposed_image_payload, publishing_api_image, attribute)
          next if empty_caption?(proposed_image_payload, publishing_api_image, attribute)

          problems << problem_description(
            "image #{attribute} doesn't match",
            publishing_api_image[attribute],
            proposed_image_payload[attribute],
          )
        end
      end
    end

    def organisation_problems
      problems = []

      unless primary_publishing_organisation_matches?
        problems << problem_description(
          "primary_publishing_organisation doesn't match",
          publishing_api_link("primary_publishing_organisation"),
          proposed_payload.dig("links", "primary_publishing_organisation"),
        )
      end

      unless organisations_match?
        problems << problem_description(
          "organisations don't match",
          publishing_api_link("organisations"),
          proposed_payload.dig("links", "organisations"),
        )
      end

      problems
    end

    def unpublishing_problems
      problems = []
      return problems unless edition.withdrawn? || edition.removed?
      return problems << "publishing api's unpublishing is missing" if publishing_api_unpublishing.blank?

      check = UnpublishingCheck.new(edition, publishing_api_unpublishing)

      unless check.expected_type?
        problems << problem_description(
          "unpublishing type not expected",
          check.expected_type,
          publishing_api_unpublishing["type"],
        )
      end

      unless check.expected_alternative_path?
        problems << problem_description(
          "unpublishing alternative path doesn't match",
          publishing_api_unpublishing["alternative_path"],
          check.expected_alternative_path,
        )
      end

      unless check.expected_unpublishing_time?
        problems << problem_description(
          "unpublishing time doesn't match",
          publishing_api_unpublishing["unpublished_at"],
          check.expected_unpublishing_time,
        )
      end

      unless check.expected_explanation?
        problems << "unpublishing explanation doesn't match"
      end

      problems
    end

    def problem_description(message, expected, actual)
      "#{message}, expected: #{expected.inspect}, actual: #{actual.inspect}"
    end

    def primary_publishing_organisation_matches?
      proposed_payload.dig("links", "primary_publishing_organisation").presence ==
        publishing_api_link("primary_publishing_organisation").presence
    end

    def organisations_match?
      proposed_payload.dig("links", "organisations").to_a.sort ==
        publishing_api_link("organisations").to_a.sort
    end

    def publishing_api_content
      @publishing_api_content ||= if edition.live?
                                    GdsApi.publishing_api
                                          .get_live_content(edition.content_id)
                                          .to_h
                                  else
                                    GdsApi.publishing_api
                                          .get_content(edition.content_id)
                                          .to_h
                                  end
    end

    def publishing_api_link(link_type)
      publishing_api_content.dig("links", link_type) ||
        publishing_api_links.dig("links", link_type)
    end

    def publishing_api_links
      @publishing_api_links ||= GdsApi.publishing_api
                                      .get_links(edition.content_id)
                                      .to_h
    end

    def empty_caption?(proposed_image_payload, publishing_api_image, attribute)
      attribute == "caption" &&
        publishing_api_image[attribute].nil? &&
        proposed_image_payload[attribute].empty?
    end

    def default_image?(proposed_image_payload, publishing_api_image, attribute)
      attribute == "alt_text" &&
        proposed_image_payload.empty? &&
        publishing_api_image[attribute] == "placeholder"
    end

    def publishing_api_unpublishing
      publishing_api_content["unpublishing"]
    end
  end
end
