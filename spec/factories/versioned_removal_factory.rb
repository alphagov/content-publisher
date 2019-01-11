# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_removal, class: Versioned::Removal do
    redirect { false }
  end
end
