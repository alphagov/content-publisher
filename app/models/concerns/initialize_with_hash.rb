# frozen_string_literal: true

module InitializeWithHash
  include ActiveSupport::Concern

  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
    @attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  alias_method :to_h, :attributes
end
