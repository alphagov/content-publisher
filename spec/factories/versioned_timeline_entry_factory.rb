# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_timeline_entry, class: Versioned::TimelineEntry do
    association :edition, factory: :versioned_edition
    association :created_by, factory: :user
    entry_type { :created }

    after(:build) do |timeline_entry, evaluator|
      unless timeline_entry.document
        timeline_entry.document = if timeline_entry.edition
                                    timeline_entry.edition.document
                                  else
                                    evaluator.association(:versioned_document)
                                  end
      end
    end
  end
end
