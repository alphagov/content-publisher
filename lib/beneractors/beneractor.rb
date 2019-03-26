# frozen_string_literal: true

require "beneractors/context"

module Beneractors
  class Beneractor
    attr_reader :context
    delegate_missing_to :@context

    def self.call(context = {})
      context = Context.new(context)

      ActiveRecord::Base.transaction do
        new(context).call
        context
      end
    rescue Context::FailError
      context
    end

    private_class_method :new

    def export(name, value)
      context[name] = value
    end

    def initialize(context)
      @context = context
    end

    def call
      pre_op
      op
      post_op
    end

    def pre_op
      context.fail!
    end

    def op
      raise "not implemented"
    end

    def post_op; end
  end
end
