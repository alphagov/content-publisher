class BackfillChangeHistoryForMetadataRevisions < ActiveRecord::Migration[6.0]
  class MetadataRevision < ApplicationRecord
    has_one :revision
  end
  class Revision < ApplicationRecord
    belongs_to :metadata_revision
    has_and_belongs_to_many :editions
  end
  class Edition < ApplicationRecord
    belongs_to :revision
  end

  disable_ddl_transaction!

  def up
    MetadataRevision.find_each do |metadata_revision|
      edition = metadata_revision.revision.editions.first
      Edition.transaction do
        edition.lock!

        change_history_editions = Edition.joins(revision: :metadata_revision)
          .where("editions.number > 1 AND editions.number < ?", edition.number)
          .where("metadata_revisions.update_type": "major")
          .where(document_id: edition.document_id)
          .order(:published_at)

        change_history = change_history_editions.map do |e|
          { id: SecureRandom.uuid,
            note: e.revision.metadata_revision.change_note,
            public_timestamp: e.published_at.rfc3339 }
        end

        metadata_revision.change_history = change_history
        metadata_revision.save!
      end
    end
  end
end
