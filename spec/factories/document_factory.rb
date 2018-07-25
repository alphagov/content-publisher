# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }
    base_path { "/#{SecureRandom.alphanumeric(8)}" }
    title { SecureRandom.alphanumeric(8) }

    trait :press_release do
      document_type "press_release"
    end
  end
end
