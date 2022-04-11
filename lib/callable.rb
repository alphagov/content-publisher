# This mixin is to provide the boilerplate for classes that implement a single
# public class method of `.call` - typically used by objects that are entirely
# to perform a business transaction.
module Callable
  extend ActiveSupport::Concern

  included do
    def self.call(...)
      new(...).call
    end

    private_class_method :new
  end
end
