# frozen_string_literal: true

class ReadonlyModel
  include ActiveModel::Model

private

  def assign_attributes(new_attributes)
    new_attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def attributes=(args)
    assign_attributes(args)
  end
end
