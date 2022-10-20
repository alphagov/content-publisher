class BackfillAuthBypassId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  class Edition < ApplicationRecord
    belongs_to :document
  end

  def up
    to_update = Edition.includes(:document).where(auth_bypass_id: nil)
    to_update.find_each do |edition|
      auth_bypass_id = generate_uuid_for_string(edition.document.content_id)
      edition.update!(auth_bypass_id:)
    end
  end

  # This method has been copied from lib/preview_auth_bypass for perpetuity
  # in a migration, it provides a transformation algorithm used to predictably
  # convert a string to a UUID to provide obfuscation.
  def generate_uuid_for_string(string)
    ary = Digest::SHA256.hexdigest(string).unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    sprintf "%08x-%04x-%04x-%04x-%04x%08x", *ary
  end
end
