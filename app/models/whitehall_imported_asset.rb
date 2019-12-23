# frozen_string_literal: true

# Represents the raw import of an asset from Whitehall Publisher and
# the import status of the asset into Content Publisher
class WhitehallImportedAsset < ApplicationRecord
  belongs_to :whitehall_import

  belongs_to :image_revision, class_name: "Image::Revision", optional: true
end
