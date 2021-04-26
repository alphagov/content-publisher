class Requirements::Form::ImageMetadataChecker
  include Requirements::Checker

  ALT_TEXT_MAX_LENGTH = 125
  CAPTION_MAX_LENGTH = 160
  CREDIT_MAX_LENGTH = 160

  attr_reader :params

  def initialize(params, **)
    @params = params.to_h.symbolize_keys
  end

  def check
    if params[:alt_text].to_s.length > ALT_TEXT_MAX_LENGTH
      issues.create(:image_alt_text, :too_long, max_length: ALT_TEXT_MAX_LENGTH)
    end

    if params[:caption].to_s.length > CAPTION_MAX_LENGTH
      issues.create(:image_caption, :too_long, max_length: CAPTION_MAX_LENGTH)
    end

    if params[:credit].to_s.length > CREDIT_MAX_LENGTH
      issues.create(:image_credit, :too_long, max_length: CREDIT_MAX_LENGTH)
    end
  end
end
