class BackfillPublishedAtForEditions < ActiveRecord::Migration[6.0]
  def up
    Status.where(state: %w[published published_but_needs_2i])
          .order(:created_at)
          .find_each { |s| s.edition.update!(published_at: s.created_at) unless s.edition.published_at }
  end
end
