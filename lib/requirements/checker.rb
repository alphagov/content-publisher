module Requirements
  module Checker
    extend ActiveSupport::Concern

    included do
      def self.call(*args, **kwargs)
        instance = new(*args, **kwargs)
        instance.check
        instance.issues
      end

      private_class_method :new
    end

    def check
      raise "Not implemented"
    end

    def issues
      @issues ||= CheckerIssues.new
    end
  end
end
