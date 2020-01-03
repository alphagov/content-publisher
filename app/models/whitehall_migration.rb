# frozen_string_literal: true

class WhitehallMigration < ApplicationRecord
  has_many :document_imports
end
