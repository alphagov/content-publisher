# frozen_string_literal: true

module Versioned
  class DebugController < BaseController
    before_action { authorise_user!(User::DEBUG_PERMISSION) }
    helper_method :revision_diff

    def index
      @document = Versioned::Document.find_by_param(params[:id])

      preload = [
        :content_revision,
        :created_by,
        :editions,
        :image_revisions,
        :lead_image_revision,
        :tags_revision,
        :update_revision,
        {
          preceded_by: %i[content_revision
                          image_revisions
                          lead_image_revision
                          tags_revision
                          update_revision],
          statuses: :created_by,
        },
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
      lead_image = revision.lead_image_revision&.as_json(except: common_except)
      images = revision.image_revisions.map { |r| r.as_json(except: common_except) }

      content.merge(tags).merge(update).merge(lead_image: lead_image, images: images)
    end
  end
end
