# frozen_string_literal: true

FactoryBot.define do
  factory :file_attachment_file_revision, class: FileAttachment::FileRevision do
    association :created_by, factory: :user

    filename { SecureRandom.hex(8) }

    transient do
      fixture { "text-file.txt" }
    end

    after(:build) do |file_revision, evaluator|
      fixture_path = Rails.root.join("spec/fixtures/files/#{evaluator.fixture}")

      file_revision.blob = ActiveStorage::Blob.build_after_upload(
        io: File.new(fixture_path),
        filename: file_revision.filename,
      )
      file_revision.size = File.size(fixture_path) unless file_revision.size
    end
  end
end
