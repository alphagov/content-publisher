# frozen_string_literal: true

module Beneractors
  class Context < OpenStruct
    class FailError < RuntimeError; end

    def abort!(failure_type)
      @failure_type = failure_type
      @success_type = false
      raise FailError
    end

    def success!(success_type = true)
      @success_type = success_type
      @failure_type = false
    end

    def success?(success_type = true)
      @success_type == success_type
    end

    def aborted?(failure_type = true)
      @failure_type == failure_type
    end
  end
end
