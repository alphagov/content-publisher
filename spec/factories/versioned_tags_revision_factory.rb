# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_tags_revision, class: Versioned::TagsRevision do
    association :created_by, factory: :user
  end
end
