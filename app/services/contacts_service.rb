# frozen_string_literal: true

class ContactsService
  def by_content_id(content_id)
    # FIXME: This might return a draft as this Publishing API method doesn't
    # distinguish between these
    document = GdsApi.publishing_api_v2.get_content(content_id)
    document["schema_name"] == "contact" ? document.to_h : nil
  rescue GdsApi::HTTPNotFound
    nil
  end
end
