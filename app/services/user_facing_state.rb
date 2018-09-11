# frozen_string_literal: true

class UserFacingState
  STATES = %w[draft submitted_for_review published_but_needs_2i published].freeze

  attr_reader :document
  delegate :review_state, :publication_state, to: :document

  def self.scope(query, state)
    case state.to_sym
    when :draft
      query
        .where(publication_state: %w[changes_not_sent_to_draft sent_to_draft sending_to_draft error_sending_to_draft error_sending_to_live])
        .where.not(review_state: "submitted_for_review")
    when :submitted_for_review
      query.where(review_state: "submitted_for_review")
    when :published_but_needs_2i
      query.where(review_state: "published_without_review")
    when :published
      # Note this includes published_but_needs_2i as this is expected to be
      # included when traversing published documents, this is a Whitehall
      # quirk we've inherited.
      query.where(publication_state: %w[sending_to_live sent_to_live])
    else
      raise "Unknown user_facing_state: #{state}"
    end
  end

  def initialize(document)
    @document = document
  end

  def to_s
    if review_state == "submitted_for_review"
      "submitted_for_review"
    elsif publication_state.in?(%w[changes_not_sent_to_draft sent_to_draft sending_to_draft error_sending_to_draft error_sending_to_live])
      "draft"
    elsif review_state == "published_without_review"
      "published_but_needs_2i"
    elsif publication_state.in?(%w[sent_to_live sending_to_live])
      "published"
    else
      raise "Encountered an unknown user facing state. review_state: #{review_state}, publication_state: #{publication_state}"
    end
  end
end
