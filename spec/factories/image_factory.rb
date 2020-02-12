FactoryBot.define do
  factory :image do
    association :created_by, factory: :user
  end
end
