# frozen_string_literal: true

module ContentDataUrlHelper
  def content_data_url(document)
    content_data_root = Plek.new.external_url_for("content-data")
    content_data_root + "/metrics" + document.live_edition.base_path
  end
end
