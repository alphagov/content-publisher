# This is an immutable model
class FileAttachment::MetadataRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  enum official_document: { unofficial: "unofficial",
                            command_paper: "command_paper",
                            act_paper: "act_paper" }

  def readonly?
    !new_record?
  end
end
