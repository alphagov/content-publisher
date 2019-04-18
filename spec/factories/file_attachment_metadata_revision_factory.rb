# frozen_string_literal: true

FactoryBot.define do
  factory :file_attachment_metadata_revision, class: FileAttachment::MetadataRevision do
    association :created_by, factory: :user
    title { SecureRandom.hex(8) }
  end
end
