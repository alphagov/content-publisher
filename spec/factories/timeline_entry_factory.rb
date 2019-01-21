# frozen_string_literal: true

FactoryBot.define do
  factory :timeline_entry do
    association :created_by, factory: :user
    edition
    entry_type { :created }

    after(:build) do |timeline_entry, evaluator|
      unless timeline_entry.document
        timeline_entry.document = if timeline_entry.edition
                                    timeline_entry.edition.document
                                  else
                                    evaluator.association(:document)
                                  end
      end
    end
  end
end
