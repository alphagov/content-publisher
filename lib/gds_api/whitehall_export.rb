# frozen_string_literal: true

module GdsApi
  def self.whitehall_export(options = {})
    GdsApi::WhitehallExport.new(
      Plek.find("whitehall-admin"),
      { bearer_token: ENV.fetch("WHITEHALL_BEARER_TOKEN", "example") }.merge(options),
    )
  end

  class WhitehallExport < Base
    def document_export(document_id)
      get_json("#{endpoint}/government/admin/export/document/#{document_id}")
    end
  end
end
