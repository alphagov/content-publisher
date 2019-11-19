# frozen_string_literal: true

module WhitehallImporter
  class AbortImportError < RuntimeError
    def initialize(message)
      super(message)
    end
  end
end
