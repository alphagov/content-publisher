# frozen_string_literal: true

# Respresents the current state of a piece of content that was once or is
# expected to be published on GOV.UK.
# It is a mutable concept that is associated with a variety of immutable
# models such as revisions and status which represent the current & past
# information on the content.
class Edition < ApplicationRecord
  self.table_name = "versioned_editions"

  before_create do
    # set a default value for last_edited_at works better than using DB default
    self.last_edited_at = Time.zone.now unless last_edited_at
  end

  after_save do
    # Store the edition on the status to keep a history
    status.update(edition: self) unless status.edition_id

    # Used to keep an audit trail of statuses a revision has held
    revision.statuses << status unless revision.statuses.include?(status)

    # Used to keep an audit trail of all the revisions that have been
    # associated with an edition
    revisions << revision unless revisions.include?(revision)
  end

  attr_readonly :number, :document_id

  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :last_edited_by, class_name: "User", optional: true

  belongs_to :document, inverse_of: :editions

  belongs_to :revision, inverse_of: :current_for_editions

  belongs_to :status, inverse_of: :status_of

  has_many :statuses, dependent: :delete_all, inverse_of: :edition

  has_many :timeline_entries, dependent: :delete_all

  has_many :internal_notes, dependent: :delete_all

  has_and_belongs_to_many :revisions,
                          -> { order("versioned_revisions.number DESC") },
                          join_table: "versioned_edition_revisions"

  delegate :content_id, :locale, :document_type, :topics, to: :document

  # delegate each state enum method
  state_methods = Status.states.keys.map { |s| (s + "?").to_sym }
  delegate :state, *state_methods, to: :status

  delegate :title,
           :title_or_fallback,
           :base_path,
           :summary,
           :contents,
           :update_type,
           :change_note,
           :major?,
           :minor?,
           :tags,
           :lead_image_revision,
           :image_revisions,
           :image_revisions_without_lead,
           to: :revision

  def self.create_initial(document, user = nil, tags = {})
    revision = Revision.create_initial(document, user, tags)
    status = Status.create!(created_by: user,
                            revision_at_creation: revision,
                            state: :draft)

    create!(created_by: user,
            current: true,
            document: document,
            last_edited_by: user,
            number: document.next_edition_number,
            revision: revision,
            status: status)
  end

  def self.create_next_edition(preceding_edition, user)
    revision = preceding_edition.revision.build_revision_update(
      { change_note: "", update_type: "major" },
      user,
    )

    status = Status.create!(created_by: user,
                            revision_at_creation: revision,
                            state: :draft)

    create!(created_by: user,
            current: true,
            document: preceding_edition.document,
            last_edited_by: user,
            number: preceding_edition.document.next_edition_number,
            revision: revision,
            status: status)
  end

  def editable?
    !live?
  end

  def resume_discarded(live_edition, user)
    revision = live_edition.revision.build_revision_update(
      { change_note: "", update_type: "major" },
      user,
    )

    status = Status.create!(created_by: user,
                            revision_at_creation: revision,
                            state: :draft)

    update!(current: true,
            last_edited_by: user,
            last_edited_at: Time.zone.now,
            revision: revision,
            status: status)
  end

  def assign_status(state,
                    user,
                    update_last_edited: true,
                    status_details: nil)
    status = Status.new(
      created_by: user,
      state: state,
      revision_at_creation_id: revision_id,
      details: status_details,
    )

    attributes = { status: status }

    if update_last_edited
      attributes[:last_edited_at] = Time.zone.now
      attributes[:last_edited_by] = user
    end

    assign_attributes(attributes)

    self
  end

  def assign_revision(revision, user)
    raise "cannot update revision on a live edition" if live?

    assign_attributes(revision: revision,
                      last_edited_by: user,
                      last_edited_at: Time.zone.now)

    self
  end
end
