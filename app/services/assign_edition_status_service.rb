# frozen_string_literal: true

class AssignEditionStatusService < ApplicationService
  def initialize(edition, user, state, update_last_edited: true, status_details: nil)
    @edition = edition
    @user = user
    @state = state
    @update_last_edited = update_last_edited
    @status_details = status_details
  end

  def call
    edition.status = Status.new(created_by: user,
                                state: state,
                                revision_at_creation: edition.revision,
                                details: status_details)

    if update_last_edited
      edition.last_edited_by = user
      edition.last_edited_at = Time.current
      edition.add_edition_editor(user)
    end
  end

private

  attr_reader :edition, :user, :state, :update_last_edited, :status_details
end
