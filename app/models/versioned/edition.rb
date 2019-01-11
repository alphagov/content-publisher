# frozen_string_literal: true

module Versioned
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
      # Add revision to the wider revisions collection
      revisions << revision unless revisions.include?(revision)
      # Store the edition on the status to keep a history
      status.update(edition: self) if status && !status.edition_id
    end

    attr_readonly :number, :document_id

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :last_edited_by,
               class_name: "User",
               optional: true,
               foreign_key: :last_edited_by_id
    # rubocop:enable Rails/InverseOf

    belongs_to :document,
               class_name: "Versioned::Document",
               inverse_of: :editions

    belongs_to :revision,
               class_name: "Versioned::Revision",
               inverse_of: :current_for_editions

    belongs_to :status,
               class_name: "Versioned::Status",
               inverse_of: :status_of

    has_many :statuses,
             class_name: "Versioned::Status",
             dependent: :delete_all,
             inverse_of: :edition

    has_many :timeline_entries,
             class_name: "Versioned::TimelineEntry",
             dependent: :delete_all

    has_many :internal_notes,
             class_name: "Versioned::InternalNote",
             dependent: :delete_all

    has_and_belongs_to_many :revisions,
                            class_name: "Versioned::Revision",
                            join_table: "versioned_edition_revisions"

    enum draft: { available: "available",
                  failure: "failure",
                  not_applicable: "not_applicable",
                  requirements_not_met: "requirements_not_met" },
         _prefix: true

    delegate :content_id, :locale, :document_type, :topics, to: :document

    # delegate each state enum method
    state_methods = Versioned::Status.states.keys.map { |s| (s + "?").to_sym }
    delegate :state, *state_methods, to: :status

    delegate_missing_to :revision

    def self.create_initial(document, user = nil, tags = {})
      revision = Revision.create_initial(document, user, tags)
      status = Status.create!(created_by: user,
                              revision_at_creation: revision,
                              state: :draft)

      create!(created_by: user,
              current: true,
              document: document,
              draft: :requirements_not_met,
              last_edited_by: user,
              number: document.next_edition_number,
              revision: revision,
              status: status)
    end

    def self.create_next_edition(proceeding_edition, user)
      revision = proceeding_edition.revision.build_revision_update(
        { change_note: "", update_type: "major" },
        user,
      )

      status = Status.create!(created_by: user,
                              revision_at_creation: revision,
                              state: :draft)

      create!(created_by: user,
              current: true,
              document: proceeding_edition.document,
              draft: :requirements_not_met,
              last_edited_by: user,
              number: proceeding_edition.document.next_edition_number,
              revision: revision,
              status: status)
    end

    def resume_discarded(proceeding_edition, user)
      revision = proceeding_edition.revision.build_revision_update(
        { change_note: "", update_type: "major" },
        user,
      )

      status = Status.create!(created_by: user,
                              revision_at_creation: revision,
                              state: :draft)

      update!(current: true,
              draft: :requirements_not_met,
              last_edited_by: user,
              last_edited_at: Time.zone.now,
              revision: revision,
              status: status)
    end

    def assign_status(state,
                      user,
                      update_last_edited: true,
                      status_details: nil)
      status = Versioned::Status.new(
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
      assign_attributes(revision: revision,
                        last_edited_by: user,
                        last_edited_at: Time.zone.now)

      self
    end
  end
end
