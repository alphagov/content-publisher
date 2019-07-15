# frozen_string_literal: true

module EditionAssertions
  class Error < StandardError
    attr_reader :edition

    def initialize(edition, assertion)
      @edition = edition
      super("Assertion failed: #{assertion}")
    end
  end

  class StateError < Error
    def initialize(edition, assertion)
      super(edition, assertion || "meets state requirements")
    end
  end

  def assert_edition_state(edition, options = {}, &block)
    return if block.call(edition)

    assertion = options[:assertion]
    assertion ||= block.to_s if block.to_s =~ /&:/ # &:editable?
    raise StateError.new(edition, assertion)
  end

  def assert_edition_access(_edition, _user)
    raise "not implemented"
  end
end
