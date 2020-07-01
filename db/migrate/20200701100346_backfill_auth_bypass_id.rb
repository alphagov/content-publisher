class BackfillAuthBypassId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  class Edition < ApplicationRecord
    belongs_to :document
  end

  def up
    to_update = Edition.includes(:document).where(auth_bypass_id: nil)
    to_update.find_each { |e| e.update!(auth_bypass_id: e.document.content_id) }
  end
end
