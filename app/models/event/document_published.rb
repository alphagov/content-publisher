class Event::DocumentPublished < ApplicationRecord
  belongs_to :document
  belongs_to :user
end
