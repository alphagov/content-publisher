class AssignEditionStatusService < ApplicationService
  def initialize(edition,
                 user: nil,
                 state:,
                 record_edit: true,
                 status_details: nil)
    @edition = edition
    @user = user
    @state = state
    @record_edit = record_edit
    @status_details = status_details
  end

  def call
    edition.status = Status.new(
      created_by: user,
      state: state,
      revision_at_creation: edition.revision,
      details: status_details,
    )

    if record_edit
      edition.last_edited_by = user
      edition.last_edited_at = Time.zone.now
      edition.add_edition_editor(user)
    end
  end

private

  attr_reader :edition, :user, :state, :record_edit, :status_details
end
