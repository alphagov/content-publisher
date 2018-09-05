# frozen_string_literal: true

class UserFacingState
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_s
    if document.review_state == "submitted_for_review"
      "submitted_for_review"
    elsif document.publication_state.in?(%w[changes_not_sent_to_draft sent_to_draft sending_to_draft error_sending_to_draft sending_to_live])
      "draft"
    elsif document.review_state == "published_without_review"
      "published_but_needs_2i"
    elsif document.publication_state == "sent_to_live"
      "published"
    else
      raise "Encountered an unknown user facing state. review_state: #{review_state}, publication_state: #{publication_state}"
    end
  end
end
