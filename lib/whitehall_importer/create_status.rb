# frozen_string_literal: true

class WhitehallImporter::CreateStatus
  attr_reader :revision, :status, :whitehall_edition, :user_ids, :edition

  SUPPORTED_WHITEHALL_STATES = %w(
    draft
    published
    rejected
    submitted
    superseded
    withdrawn
  ).freeze

  def initialize(revision, status, whitehall_edition, user_ids, edition: nil)
    @revision = revision
    @status = status
    @whitehall_edition = whitehall_edition
    @user_ids = user_ids
    @edition = edition
  end

  def call
    check_supported_state
    event = state_history_event(status)

    Status.new(
      state: state,
      revision_at_creation: revision,
      created_by_id: user_ids[event["whodunnit"]],
      created_at: event["created_at"],
      details: details,
    )
  end

private

  def check_supported_state
    raise WhitehallImporter::AbortImportError, "Edition has an unsupported state" unless valid_state?
  end

  def valid_state?
    SUPPORTED_WHITEHALL_STATES.include?(status)
  end

  def state_history_event(status)
    event = whitehall_edition["revision_history"].select { |h| h["state"] == status }.last

    raise WhitehallImporter::AbortImportError, "Edition is missing a #{state} event" unless event

    event
  end

  def state
    case status
    when "draft" then "draft"
    when "superseded" then "superseded"
    when "published"
      whitehall_edition["force_published"] ? "published_but_needs_2i" : "published"
    when "withdrawn" then "withdrawn"
    else
      "submitted_for_review"
    end
  end

  def details
    if edition && status == "withdrawn"
      if whitehall_edition["unpublishing"].blank?
        raise WhitehallImporter::AbortImportError, "Cannot create withdrawn status without an unpublishing"
      end

      Withdrawal.new(
        published_status: edition.status,
        public_explanation: whitehall_edition["unpublishing"]["explanation"],
        withdrawn_at: whitehall_edition["unpublishing"]["created_at"],
      )
    end
  end
end
