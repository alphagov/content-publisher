# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    document
    filename { "my-image.jpg" }
    width { 1000 }
    height { 1000 }
    crop_x { 0 }
    crop_y { 166 }
    crop_width { 1000 }
    crop_height { 667 }

    transient do
      fixture { "1000x1000.jpg" }
    end

    after(:build) do |image, evaluator|
      fixture_path = Rails.root.join("spec/fixtures/files/#{evaluator.fixture}")

      image.blob = ActiveStorage::Blob.build_after_upload(
        io: File.new(fixture_path),
        filename: image.filename,
      )
    end
  end
end
