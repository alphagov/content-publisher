module WhitehallImporter
  class IntegrityChecker::BodyTextCheck
    attr_reader :proposed_body_text, :publishing_api_body_text

    def initialize(proposed_body_text, publishing_api_body_text)
      @proposed_body_text = proposed_body_text
      @publishing_api_body_text = publishing_api_body_text
    end

    def sufficiently_similar?
      Sanitize.clean(publishing_api_body_text).squish == Sanitize.clean(proposed_body_text).squish
    end
  end
end
