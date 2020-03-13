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
  end
end
