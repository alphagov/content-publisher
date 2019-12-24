# frozen_string_literal: true

require "gds_api/base"

class GdsApi::Whitehall < GdsApi::Base
  def document_list(organisation_content_id, document_type)
    params = {
      lead_organisation: organisation_content_id,
      type: document_type,
      page_number: 1,
      page_count: 100,
    }
    Enumerator.new do |yielder|
      next_link = document_list_url(params)
      while next_link
        yielder.yield begin
          response = get_json(next_link).to_hash
        end
        params[:page_number] += 1
        next_link = response["page_count"] == params[:page_count] ? document_list_url(params) : false
      end
    end
  end

  def document_export(document_id)
    path = "#{endpoint}/government/admin/export/document/#{document_id}"
    response = get_json(path)
    response.to_hash
  end

private

  def document_list_url(params)
    "#{endpoint}/government/admin/export/document?#{params.to_query}"
  end
end
