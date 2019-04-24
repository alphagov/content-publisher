# frozen_string_literal: true

# This stores the data for an Image::Revision about the image such as
# alt_text caption. This is distinct from Image::BlobRevision as it is data
# that when changed doesn't require changing the files on Asset Manager.
#
# This model is immutable
class Image::MetadataRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  def readonly?
    !new_record?
  end
end
