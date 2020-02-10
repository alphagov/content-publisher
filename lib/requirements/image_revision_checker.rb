# frozen_string_literal: true

module Requirements
  class ImageRevisionChecker
    ALT_TEXT_MAX_LENGTH = 125
    CAPTION_MAX_LENGTH = 160
    CREDIT_MAX_LENGTH = 160

    attr_reader :image_revision

    def initialize(image_revision)
      @image_revision = image_revision
    end

    def pre_update_issues(params)
      issues = CheckerIssues.new

      if params[:alt_text].blank?
        issues.create(:alt_text,
                      :blank,
                      filename: image_revision.filename,
                      image_revision: image_revision)
      end

      if params[:alt_text].to_s.length > ALT_TEXT_MAX_LENGTH
        issues.create(:alt_text,
                      :too_long,
                      max_length: ALT_TEXT_MAX_LENGTH,
                      filename: image_revision.filename,
                      image_revision: image_revision)
      end

      if params[:caption].to_s.length > CAPTION_MAX_LENGTH
        issues.create(:caption,
                      :too_long,
                      max_length: CAPTION_MAX_LENGTH,
                      filename: image_revision.filename,
                      image_revision: image_revision)
      end

      if params[:credit].to_s.length > CREDIT_MAX_LENGTH
        issues.create(:credit,
                      :too_long,
                      max_length: CREDIT_MAX_LENGTH,
                      filename: image_revision.filename,
                      image_revision: image_revision)
      end

      issues
    end

    def pre_preview_issues
      pre_update_issues(alt_text: image_revision.alt_text,
                        caption: image_revision.caption,
                        credit: image_revision.credit)
    end
  end
end
