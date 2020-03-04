FactoryBot.define do
  factory :removal do
    redirect { false }
    removed_at { Date.yesterday.noon }
  end
end
