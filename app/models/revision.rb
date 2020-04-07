# Represents a particular revision of a document - acting as a snapshot to
# a particular user's edit.
#
# This model stores as little data as possible by having associations to more
# specific types of revision and delegating its methods to them.
#
# This model is immutable
class Revision < ApplicationRecord
  COMPARISON_IGNORE_FIELDS = %w[id number created_at created_by_id].freeze

  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :lead_image_revision, class_name: "Image::Revision", optional: true

  belongs_to :document

  belongs_to :content_revision

  belongs_to :metadata_revision

  belongs_to :tags_revision

  belongs_to :preceded_by,
             class_name: "Revision",
             optional: true

  has_and_belongs_to_many :statuses, -> { order("statuses.created_at DESC") }

  has_and_belongs_to_many :editions, -> { order("editions.number DESC") }

  has_and_belongs_to_many :image_revisions,
                          -> { order("image_revisions.image_id ASC") },
                          class_name: "Image::Revision",
                          association_foreign_key: "image_revision_id",
                          join_table: "revisions_image_revisions"

  has_and_belongs_to_many :file_attachment_revisions,
                          -> { order("file_attachment_revisions.file_attachment_id ASC") },
                          class_name: "FileAttachment::Revision",
                          association_foreign_key: "file_attachment_revision_id",
                          join_table: "revisions_file_attachment_revisions"

  delegate :title,
           :base_path,
           :summary,
           :contents,
           :title_or_fallback,
           to: :content_revision

  delegate :update_type,
           :change_note,
           :change_history,
           :major?,
           :minor?,
           :proposed_publish_time,
           :backdated_to,
           :document_type,
           :editor_political,
           :featured_attachment_ordering,
           to: :metadata_revision

  delegate :tags,
           :primary_publishing_organisation_id,
           :supporting_organisation_ids,
           to: :tags_revision

  def readonly?
    !new_record?
  end

  def image_revisions_without_lead
    image_revisions.reject { |i| i.id == lead_image_revision_id }
  end

  def assets
    image_revisions.flat_map(&:assets) + file_attachment_revisions.map(&:asset)
  end

  def featured_attachments
    file_attachment_revisions.sort_by do |attachment|
      featured_attachment_ordering.find_index(attachment.featured_attachment_id) || Float::INFINITY
    end
  end
end
