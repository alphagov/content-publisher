# frozen_string_literal: true

class ImageDeleteService
  attr_reader :image

  def initialize(image)
    @image = image
  end

  def call
    if image.publication_state == "sent_to_live"
      raise "Cannot delete live images"
    end

    AssetManagerService.new.delete(image)
    image.destroy!
  end
end
