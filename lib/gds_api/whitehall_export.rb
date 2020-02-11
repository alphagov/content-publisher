# frozen_string_literal: true

module GdsApi
  def self.whitehall_export(options = {})
    GdsApi::WhitehallExport.new(
      Plek.find("whitehall-admin"),
      { bearer_token: ENV.fetch("WHITEHALL_BEARER_TOKEN", "example") }.merge(options),
    )
  end

  class WhitehallExport < Base
    def document_list(organisation_content_id, document_type, document_subtypes = [])
      params = {
        lead_organisation: organisation_content_id,
        type: document_type,
        page_number: 1,
        page_count: 100,
        subtypes: document_subtypes,
      }
      Enumerator.new do |yielder|
        next_link = document_list_url(params)
        while next_link
          yielder.yield begin
            response = get_json(next_link)
          end
          params[:page_number] += 1
          next_link = response["page_count"] == params[:page_count] ? document_list_url(params) : false
        end
      end
    end

    def document_export(document_id)
      get_json("#{endpoint}/government/admin/export/document/#{document_id}")
    end

    def lock_document(document_id)
      post_json("#{endpoint}/government/admin/export/document/#{document_id}/lock")
    end

    def unlock_document(document_id)
      post_json("#{endpoint}/government/admin/export/document/#{document_id}/unlock")
    end

    def document_migrated(document_id)
      post_json("#{endpoint}/government/admin/export/document/#{document_id}/migrated")
    end

  private

    def document_list_url(params)
      "#{endpoint}/government/admin/export/document?#{params.to_query}"
    end
  end
end
