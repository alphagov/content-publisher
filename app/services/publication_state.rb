# frozen_string_literal: true

class PublicationState
  STATES = %w[
    newly_created
    changes_not_sent_to_draft
    sending_to_draft
    sent_to_draft
    error_sending_to_draft
  ].freeze
end
