# frozen_string_literal: true

class PopulateEditionEditors < ActiveRecord::Migration[6.0]
  def change
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
