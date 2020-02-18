class WhitehallMigrationController < ApplicationController
  before_action { authorise_user!(User::DEBUG_PERMISSION) }

  def show
    @whitehall_migration = WhitehallMigration.find(params[:migration_id])
  end

  def documents
    whitehall_migration = WhitehallMigration.find(params[:migration_id])
    @documents = whitehall_migration.document_imports
  end

  def document
    @document = WhitehallMigration::DocumentImport.find_by!(
      id: params[:document_import_id],
      whitehall_migration_id: params[:migration_id],
    )
  end
end
