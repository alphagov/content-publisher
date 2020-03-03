class BackfillRemovalsRemovedAt < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  class Removal < ApplicationRecord; end

  def up
    Removal.find_each { |removal| removal.update!(removed_at: removal.created_at) }
  end
end
