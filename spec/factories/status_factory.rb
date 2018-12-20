# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    state { :draft }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :revision

    trait :withdrawn do
      state { :withdrawn }
      association :details, factory: :withdrawal
    end
  end

  trait :withdrawn do
    state { :withdrawn }
    association :details, factory: :withdrawal
  end
end
