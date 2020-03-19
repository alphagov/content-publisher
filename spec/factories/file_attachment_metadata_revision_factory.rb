FactoryBot.define do
  factory :file_attachment_metadata_revision, class: "FileAttachment::MetadataRevision" do
    association :created_by, factory: :user
    title { SecureRandom.hex(8) }
    unique_reference { SecureRandom.alphanumeric(10) }
  end
end
