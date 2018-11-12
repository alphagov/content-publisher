# frozen_string_literal: true

class ImageDraftingRequirements
  ALT_TEXT_MAX_LENGTH = 125
  CAPTION_MAX_LENGTH = 160

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def errors
    messages = Hash.new { |h, k| h[k] = [] }

    if @image.alt_text.blank?
      messages["alt_text"] << I18n.t!("document_images.edit.flashes.drafting_requirements.alt_text_presence")
    end

    if @image.alt_text.length > ALT_TEXT_MAX_LENGTH
      messages["alt_text"] << I18n.t!("document_images.edit.flashes.drafting_requirements.alt_text_max_length",
                                     field: "Alt text",
                                     max_length: ALT_TEXT_MAX_LENGTH)
    end

    if @image.caption.length > CAPTION_MAX_LENGTH
      messages["caption"] << I18n.t!("document_images.edit.flashes.drafting_requirements.caption_max_length",
                                    field: "Caption",
                                    max_length: CAPTION_MAX_LENGTH)
    end

    messages
  end
end
