module Assertions
  class Error < StandardError
    def initialize(assertion)
      super("Assertion failed: #{assertion}")
    end
  end

  class ErrorWithEdition < Error
    attr_reader :edition

    def initialize(edition, assertion)
      @edition = edition
      super(assertion)
    end
  end

  class PermissionError < Error
    attr_reader :permission

    def initialize(permission)
      @permission = permission
      super("user has #{permission} permission")
    end
  end

  class AccessError < Error; end

  def assert_with_edition(edition, options = {}, &block)
    return if block.call(edition)
    assertion = options[:assertion] || block.inspect
    raise ErrorWithEdition.new(edition, assertion)
  end

  def assert_access(edition, user)
    # TODO
  end

  def assert_permission(user, permission)
    return if user.has_permission?(permission)
    raise PermissionError.new(permission)
  end
end
