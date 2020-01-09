# frozen_string_literal: true

module WhitehallImporter
  class IntegrityCheckError < AbortImportError
    attr_reader :problems, :payload

    def initialize(integrity_check)
      @problems = integrity_check.problems
      @payload = integrity_check.proposed_payload

      publishing_status = integrity_check.edition.live? ? "live" : "draft"
      super("#{publishing_status.titleize} integrity check failed")
    end
  end
end
