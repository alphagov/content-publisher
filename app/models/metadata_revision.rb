# This stores the metadata component of a revision, by metadata we mean
# supporting data that explains the revision which is represented by
# update_type and change_note fields.
#
# This model is immutable.
class MetadataRevision < ApplicationRecord
  validates_each :change_history do |record, attribute, change_notes|
    uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\Z/

    change_notes.each do |change_note|
      unless change_note.keys.sort == %w(id note public_timestamp)
        record.errors.add(attribute, "has an entry with invalid keys", strict: true)
      end
      unless change_note["id"].match?(uuid_regex)
        record.errors.add(attribute, "has an entry with a non UUID id", strict: true)
      end
      begin
        Time.zone.rfc3339(change_note["public_timestamp"])
      rescue ArgumentError
        record.errors.add(attribute, "has an entry with an invalid timestamp", strict: true)
      end
    end
  end

  belongs_to :created_by, class_name: "User", optional: true

  enum update_type: { major: "major", minor: "minor" }

  def readonly?
    !new_record?
  end

  def document_type
    DocumentType.find(document_type_id)
  end
end
