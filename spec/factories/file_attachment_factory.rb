# frozen_string_literal: true

FactoryBot.define do
  factory :file_attachment do
    association :created_by, factory: :user
  end
end
