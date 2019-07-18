module Formats
  class Field
    attr_reader :id, :label

    include InitializeWithHash

    def self.for(opts)
      "Formats::#{opts["id"].camelize}Field".constantize.new(opts)
    end

    def update(params, updater)
      raise "not implemented"
    end
  end
end
