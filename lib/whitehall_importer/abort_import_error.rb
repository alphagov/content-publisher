module WhitehallImporter
  class AbortImportError < RuntimeError
    def initialize(message)
      super(message)
    end
  end
end
