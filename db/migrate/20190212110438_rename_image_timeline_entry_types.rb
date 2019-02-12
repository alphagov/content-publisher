# frozen_string_literal: true

class RenameImageTimelineEntryTypes < ActiveRecord::Migration[5.2]
  def up
    TimelineEntry.where(entry_type: "lead_image_updated")
      .update_all(entry_type: "lead_image_selected")

    TimelineEntry.where(entry_type: "image_removed")
      .update_all(entry_type: "image_deleted")
  end

  def down
    TimelineEntry.where(entry_type: "lead_image_selected")
      .update_all(entry_type: "lead_image_updated")

    TimelineEntry.where(entry_type: "image_deleted")
      .update_all(entry_type: "image_removed")
  end
end
