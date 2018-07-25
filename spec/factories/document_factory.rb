# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }

    trait :press_release do
      document_type "press_release"
    end
  end
end
