class AddFeaturedAttachmentOrdering < ActiveRecord::Migration[6.0]
  def change
    add_column :metadata_revisions, :featured_attachment_ordering, :string, array: true, default: [], null: false
  end
end
