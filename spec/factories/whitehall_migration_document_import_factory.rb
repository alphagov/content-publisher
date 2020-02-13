FactoryBot.define do
  factory :whitehall_migration_document_import, class: "WhitehallMigration::DocumentImport" do
    state { "pending" }
    payload { build(:whitehall_export_document) }
    whitehall_document_id { payload["id"] }
    content_id { payload["content_id"] }
    document { association :document, imported_from: "whitehall" }
    whitehall_migration
  end
end
