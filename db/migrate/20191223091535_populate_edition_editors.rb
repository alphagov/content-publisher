class PopulateEditionEditors < ActiveRecord::Migration[6.0]
  class Edition < ApplicationRecord
    has_and_belongs_to_many :edition_editors,
                            class_name: "User",
                            join_table: :edition_editors
  end

  def up
    revision_editors = Revision.joins(:editions_revisions)
                       .group(:edition_id)
                       .pluck(:edition_id, Arel.sql("ARRAY_AGG(DISTINCT created_by_id)"))
                       .to_h

    status_editors = Status.group(:edition_id)
                     .pluck(:edition_id, Arel.sql("ARRAY_AGG(DISTINCT created_by_id)"))
                     .to_h

    Edition.all.each do |edition|
      editor_ids = (revision_editors[edition.id] + status_editors[edition.id]).uniq
      edition.edition_editor_ids = editor_ids
    end
  end
end
