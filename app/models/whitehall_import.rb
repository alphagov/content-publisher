# frozen_string_literal: true

# Represents the raw import of a document from Whitehall Publisher and
# the import status of the document into Content Publisher
class WhitehallImport < ApplicationRecord
  enum state: { importing: "importing",
                completed: "completed",
                failed: "failed" }
end
