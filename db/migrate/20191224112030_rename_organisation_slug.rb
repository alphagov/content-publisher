class RenameOrganisationSlug < ActiveRecord::Migration[6.0]
  def change
    rename_column :whitehall_migrations, :organisation_slug, :organisation_content_id
  end
end
