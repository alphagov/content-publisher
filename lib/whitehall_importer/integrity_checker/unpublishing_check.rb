module WhitehallImporter
  class IntegrityChecker::UnpublishingCheck
    attr_reader :edition, :unpublishing

    def initialize(edition, unpublishing)
      @edition = edition
      @unpublishing = unpublishing
    end

    def expected_type?
      case unpublishing["type"]
      when "gone"
        edition.removed? && !edition.status.details.redirect?
      when "redirect"
        edition.removed? && edition.status.details.redirect?
      when "withdrawal"
        edition.withdrawn?
      else
        false
      end
    end

    def expected_unpublishing_time?
      return true unless edition.withdrawn?

      unpublishing_time_matches?
    end

  private

    def unpublishing_time_matches?
      IntegrityChecker.time_matches?(
        unpublishing["unpublished_at"],
        edition.status.details.withdrawn_at&.rfc3339,
      )
    end
  end
end
