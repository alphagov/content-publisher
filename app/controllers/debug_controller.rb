# frozen_string_literal: true

class DebugController < ApplicationController
  before_action { authorise_user!(User::DEBUG_PERMISSION) }
  helper_method :revision_diff

  def index
    @document = Document.find_by_param(params[:document])

    image_preload = {
      lead_image_revision: %i[blob_revision metadata_revision],
      image_revisions: %i[blob_revision metadata_revision],
    }

    preload = [
      :content_revision,
      :created_by,
      :editions,
      :tags_revision,
      :metadata_revision,
      {
        preceded_by: %i[content_revision
                        image_revisions
                        lead_image_revision
                        tags_revision
                        metadata_revision] << image_preload,
        statuses: :created_by,
      }.merge(image_preload),
    ]

    @revisions = Revision.where(document: @document)
                         .preload(*preload)
                         .order(number: :desc)
                         .page(params.fetch(:page, 1))
                         .per(25)
  end

  def revision_diff(revision)
    old = revision.preceded_by ? revision_hash(revision.preceded_by) : {}
    new = revision_hash(revision)
    Hashdiff.diff(old, new, use_lcs: false)
  end

  def revision_hash(revision)
    common_except = %i[id created_at created_by_id]
    content = revision.content_revision.as_json(except: common_except)
    tags = revision.tags_revision.as_json(except: common_except)
    metadata = revision.metadata_revision.as_json(except: common_except)
    lead_image = image_revision_hash(revision.lead_image_revision)
    images = revision.image_revisions.map { |r| image_revision_hash(r) }
    file_attachments = revision.file_attachment_revisions.map { |r| file_attachment_revision_hash(r) }

    content.merge(tags).merge(metadata).merge(lead_image: lead_image,
                                              images: images,
                                              file_attachments: file_attachments)
  end

  def image_revision_hash(image_revision)
    return nil unless image_revision

    common_except = %i[id created_at created_by_id]
    blob_revision = image_revision.blob_revision.as_json(except: common_except)
    metadata_revision = image_revision.metadata_revision.as_json(except: common_except)

    blob_revision.merge(metadata_revision)
  end

  def file_attachment_revision_hash(file_attachment_revision)
    return nil unless file_attachment_revision

    common_except = %i[id created_at created_by_id]
    blob_revision = file_attachment_revision.blob_revision.as_json(except: common_except)
    metadata_revision = file_attachment_revision.metadata_revision.as_json(except: common_except)

    blob_revision.merge(metadata_revision)
  end
end
