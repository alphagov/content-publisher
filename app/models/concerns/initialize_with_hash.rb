# frozen_string_literal: true

module InitializeWithHash
  include ActiveSupport::Concern

  def initialize(params)
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
end
