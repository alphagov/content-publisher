class AddPublishedAtToEditions < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :published_at, :datetime
  end
end
