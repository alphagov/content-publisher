# frozen_string_literal: true

require "gds_api/base"

class GdsApi::Whitehall < GdsApi::Base
  def document_export(document_id)
    path = "#{endpoint}/government/admin/export/document/#{document_id}"
    response = get_json(path)
    response.to_hash
  end
end
