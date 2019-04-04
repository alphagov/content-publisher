# frozen_string_literal: true

class ContentDataUrl
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def url
    content_data_root = Plek.new.external_url_for("content-data-admin")
    content_data_root + "/metrics" + document.live_edition.base_path
  end
end
