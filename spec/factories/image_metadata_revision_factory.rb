# frozen_string_literal: true

FactoryBot.define do
  factory :image_metadata_revision, class: Image::MetadataRevision do
    association :created_by, factory: :user
  end
end
