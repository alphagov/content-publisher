# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :document
  belongs_to :blob, class_name: "ActiveStorage::Blob" # rubocop:disable Rails/InverseOf
end
