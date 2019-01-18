# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_image_metadata_revision, class: Versioned::Image::MetadataRevision do
    association :created_by, factory: :user
  end
end
