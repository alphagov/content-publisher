# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_imported_entry, class: TimelineEntry::WhitehallImportedEntry do
    entry_type { :new_edition }
  end
end
