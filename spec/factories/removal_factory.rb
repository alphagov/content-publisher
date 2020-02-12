FactoryBot.define do
  factory :removal do
    redirect { false }
    created_at { Date.yesterday.noon }
  end
end
