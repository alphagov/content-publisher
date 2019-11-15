# frozen_string_literal: true

FactoryBot.define do
  factory :metadata_revision do
    update_type { "major" }
    document_type_id { build(:document_type, path_prefix: "/prefix").id }
    association :created_by, factory: :user
  end
end
