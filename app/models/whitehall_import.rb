# frozen_string_literal: true

# Represents the raw import of a document from Whitehall Publisher and
# the import status of the document into Content Publisher
class WhitehallImport < ApplicationRecord
  belongs_to :document, optional: true

  enum state: { importing: "importing",
                completed: "completed",
                failed: "failed" }
end
