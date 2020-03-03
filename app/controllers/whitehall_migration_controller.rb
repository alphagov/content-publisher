class WhitehallMigrationController < ApplicationController
  before_action { authorise_user!(User::DEBUG_PERMISSION) }

  def show
    @whitehall_migration = WhitehallMigration.find(params[:migration_id])
  end

  def document_imports
    @whitehall_migration = WhitehallMigration.find(params[:migration_id])
    @state = params[:state] if WhitehallMigration::DocumentImport.states.keys.include?(params[:state])
    scope = @whitehall_migration.document_imports
    scope = scope.where(state: @state) if @state
    @document_imports = scope.order(:id).page(params.fetch(:page, 1)).per(50)
  end

  def document_import
    @document_import = WhitehallMigration::DocumentImport.find_by!(
      id: params[:document_import_id],
      whitehall_migration_id: params[:migration_id],
    )
  end
end
