# frozen_string_literal: true

FactoryBot.define do
  factory :content_revision do
    title { SecureRandom.alphanumeric(10) }
    base_path { title ? "/prefix/#{title.parameterize}" : nil }
    association :created_by, factory: :user
  end
end
