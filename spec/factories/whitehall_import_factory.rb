# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_import do
    state { "importing" }
    payload { build(:whitehall_export_document) }
    whitehall_document_id { payload["id"] }
    content_id { payload["content_id"] }
    document { association :document, imported_from: "whitehall" }
    assets { [] }
  end
end
