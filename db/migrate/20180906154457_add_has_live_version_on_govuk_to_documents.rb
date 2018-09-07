class AddHasLiveVersionOnGovukToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :has_live_version_on_govuk, :boolean, default: false, null: false
  end
end
