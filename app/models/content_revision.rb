# frozen_string_literal: true

# This stores the content component of a revision, such as title, body and
# other data a particular format uses.
#
# This model is immutable.
class ContentRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  def readonly?
    !new_record?
  end

  def title_or_fallback
    title.presence || I18n.t!("documents.untitled_document")
  end
end
