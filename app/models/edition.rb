# frozen_string_literal: true

# Respresents the current state of a piece of content that was once or is
# expected to be published on GOV.UK.
#
# It is a mutable concept that is associated with a revision model and status
# model to represent the current content and state of the edition.
class Edition < ApplicationRecord
  before_create do
    # set a default value for last_edited_at works better than using DB default
    self.last_edited_at = Time.current unless last_edited_at
  end

  after_save do
    # Store the edition on the status to keep a history
    status.update!(edition: self) unless status.edition_id

    # Used to keep an audit trail of statuses a revision has held
    revision.statuses << status unless revision.statuses.include?(status)

    # An edition points to a single revision, however we want to mantain a log
    # of all joins between revision and edition. Revision has a many-to-many
    # edition association that we use for storing this (to avoid the complexity
    # of an edition having revision and revsions methods). Typically a revision
    # would only be associated with a single edition.
    revision.editions << self unless revision.editions.include?(self)
  end

  attr_readonly :number, :document_id

  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :last_edited_by, class_name: "User", optional: true

  belongs_to :document

  belongs_to :revision

  belongs_to :status

  belongs_to :access_limit, optional: true

  has_many :timeline_entries

  has_and_belongs_to_many :revisions

  has_many :statuses

  has_many :internal_notes

  delegate :content_id, :locale, :topics, :document_topics, to: :document

  # delegate each state enum method
  state_methods = Status.states.keys.map { |s| (s + "?").to_sym }
  delegate :state, *state_methods, to: :status

  delegate :title,
           :title_or_fallback,
           :base_path,
           :document_type,
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
           :proposed_publish_time,
           :file_attachment_revisions,
           :assets,
           :primary_publishing_organisation_id,
           :supporting_organisation_ids,
           :backdated_to,
           :editor_political,
           to: :revision

  scope :find_current, ->(id: nil, document: nil) do
    find_by = {}.tap do |criteria|
      criteria[:id] = id if id

      if document
        content_id, locale = document.split(":")
        criteria[:documents] = { content_id: content_id, locale: locale }
      end
    end

    join_tables = %i[document revision status]
    where(current: true)
      .joins(join_tables)
      .includes(join_tables)
      .find_by!(find_by)
  end

  scope :political, ->(political = true) do
    sql = "CASE WHEN metadata_revisions.editor_political IS NULL "\
          "THEN editions.system_political = :political "\
          "ELSE metadata_revisions.editor_political = :political "\
          "END"

    joins(revision: :metadata_revision).where(sql, political: political)
  end

  scope :history_mode, ->(history_mode = true) do
    if history_mode
      political.where.not(government_id: [nil, Government.current.content_id])
    else
      political(false)
        .or(political.where(government_id: [nil, Government.current.content_id]))
    end
  end

  def self.create_initial(document:, document_type_id:, user: nil, tags: {})
    revision = Revision.create_initial(
      document: document,
      user: user,
      tags: tags,
      document_type_id: document_type_id,
    )
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

  def editable?
    !live? && !scheduled?
  end

  def first?
    number == 1
  end

  def political?
    editor_political.nil? ? system_political : editor_political
  end

  def history_mode?
    return false unless government

    political? && !government.current?
  end

  def government
    return unless government_id

    Government.find(government_id)
  end

  def assign_status(state,
                    user,
                    update_last_edited: true,
                    status_details: nil)
    status = Status.new(
      created_by: user,
      state: state,
      revision_at_creation: revision,
      details: status_details,
    )

    attributes = { status: status }

    if update_last_edited
      assign_as_edit(user, attributes)
    else
      assign_attributes(attributes)
      self
    end
  end

  def assign_as_edit(user, attributes)
    assign_attributes(
      attributes.merge(last_edited_by: user, last_edited_at: Time.current),
    )

    self
  end

  def assign_revision(revision, user)
    raise "cannot update revision on a live edition" if live?

    assign_as_edit(user, revision: revision)
  end

  def editors
    user_ids = statuses.pluck(:created_by_id) + revisions.pluck(:created_by_id)
    User.where(id: user_ids.uniq)
  end

  def access_limit_organisation_ids
    raise "no access limit" unless access_limit

    orgs = [primary_publishing_organisation_id]
    orgs += supporting_organisation_ids if access_limit.tagged_organisations?
    orgs
  end
end
