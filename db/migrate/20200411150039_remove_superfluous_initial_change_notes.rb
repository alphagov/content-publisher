class RemoveSuperfluousInitialChangeNotes < ActiveRecord::Migration[6.0]
  def up
    MetadataRevision.where(change_note: "First published.")
                    .update_all(change_note: nil)
  end
end
