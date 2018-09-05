# frozen_string_literal: true

class UserFacingState
  attr_reader :document
  delegate :review_state, :publication_state, to: :document

  def initialize(document)
    @document = document
  end

  def to_s
    if review_state == "submitted_for_review"
      "submitted_for_review"
    elsif publication_state.in?(%w[changes_not_sent_to_draft sent_to_draft sending_to_draft error_sending_to_draft sending_to_live])
      "draft"
    elsif review_state == "published_without_review"
      "published_but_needs_2i"
    elsif publication_state.in?(%w[sent_to_live error_sending_to_live])
      "published"
    else
      raise "Encountered an unknown user facing state. review_state: #{review_state}, publication_state: #{publication_state}"
    end
  end
end
