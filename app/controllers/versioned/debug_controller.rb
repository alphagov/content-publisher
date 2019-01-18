# frozen_string_literal: true

module Versioned
  class DebugController < BaseController
    before_action { authorise_user!(User::DEBUG_PERMISSION) }
    helper_method :revision_diff

    def index
      @document = Versioned::Document.find_by_param(params[:id])

      image_preload = {
        lead_image_revision: %i[file_revision metadata_revision],
        image_revisions: %i[file_revision metadata_revision],
      }

      preload = [
        :content_revision,
        :created_by,
        :editions,
        :tags_revision,
        :update_revision,
        {
          preceded_by: %i[content_revision
                          image_revisions
                          lead_image_revision
                          tags_revision
                          update_revision] << image_preload,
          statuses: :created_by,
        }.merge(image_preload),
      ]

      @revisions = Versioned::Revision.where(document: @document)
                                      .preload(*preload)
                                      .order(number: :desc)
                                      .page(params.fetch(:page, 1))
                                      .per(25)
    end

    def revision_diff(revision)
      old = revision.preceded_by ? revision_hash(revision.preceded_by) : {}
      new = revision_hash(revision)
      HashDiff.diff(old, new, use_lcs: false)
    end

    def revision_hash(revision)
      common_except = %i[id created_at created_by_id]
      content = revision.content_revision.as_json(except: common_except)
      tags = revision.tags_revision.as_json(except: common_except)
      update = revision.update_revision.as_json(except: common_except)
      lead_image = image_revision_hash(revision.lead_image_revision)
      images = revision.image_revisions.map { |r| image_revision_hash(r) }

      content.merge(tags).merge(update).merge(lead_image: lead_image, images: images)
    end

    def image_revision_hash(image_revision)
      return nil unless image_revision

      common_except = %i[id created_at created_by_id]
      file_revision = image_revision.file_revision.as_json(except: common_except)
      metadata_revision = image_revision.metadata_revision.as_json(except: common_except)

      file_revision.merge(metadata_revision)
    end
  end
end
