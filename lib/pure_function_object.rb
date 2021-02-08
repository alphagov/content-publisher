# This applies the pure-function-as-an-object pattern to classes, allowing a
# class to operate as a function but implemented as a class.
#
# Classes which use this mixin have a single public method of `.call` which is
# a class method. Within the object there is an  #initialize method
# which is used to assign instance variable and a #call method which is used
# to perform the work.
module PureFunctionObject
  extend ActiveSupport::Concern

  included do
    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    private_class_method :new
  end
end
