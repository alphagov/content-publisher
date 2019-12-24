# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_index, class: Hash do
    skip_create

    documents do
      [
        build(:whitehall_export_index_document),
      ]
    end

    page_count { documents.size }
    sequence(:page_number, 1)

    initialize_with { attributes.stringify_keys }
  end
end
