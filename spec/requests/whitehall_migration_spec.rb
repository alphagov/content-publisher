RSpec.describe "Whitehall Migration" do
  let(:whitehall_migration) { create(:whitehall_migration) }
  let(:document_import) { create(:whitehall_migration_document_import, whitehall_migration: whitehall_migration) }
  let(:debug_permission_user) { create(:user, permissions: [User::DEBUG_PERMISSION]) }

  it_behaves_like "requests that return status",
                  "when a user without debug permissions looks at a whitehall migration",
                  status: :forbidden,
                  routes: { whitehall_migration_path: %i[get],
                          whitehall_migration_documents_path: %i[get] } do
    before { login_as(create(:user)) }

    let(:route_params) { [whitehall_migration] }
  end

  it_behaves_like "requests that return status",
                  "when a user without debug permissions looks at a whitehall migration document",
                  status: :forbidden,
                  routes: { whitehall_migration_document_path: %i[get] } do
    before { login_as(create(:user)) }

    let(:route_params) do
      [whitehall_migration, document_import]
    end
  end

  describe "GET /whitehall-migration/:migration_id" do
    it "returns success" do
      login_as(debug_permission_user)
      get whitehall_migration_path(whitehall_migration)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /whitehall-migration/:migration_id/documents" do
    it "returns success" do
      login_as(debug_permission_user)
      create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration.id)
      get whitehall_migration_documents_path(whitehall_migration.id)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /whitehall-migration/:migration_id/documents/:document_import_id" do
    it "returns success" do
      login_as(debug_permission_user)
      document_import = create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration.id)
      get whitehall_migration_document_path(whitehall_migration.id, document_import.id)

      expect(response).to have_http_status(:ok)
    end
  end
end
