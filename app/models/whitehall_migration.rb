class WhitehallMigration < ApplicationRecord
  has_many :document_imports

  def check_migration_finished
    update!(finished_at: Time.zone.now) if document_imports.in_progress.empty?
  end
end
