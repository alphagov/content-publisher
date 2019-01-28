# frozen_string_literal: true

class GovspeakDocument
  attr_reader :text

  def initialize(text, edition)
    @text = text
    @edition = edition
  end

  def in_app_html
    Govspeak::Document.new(text, contacts: contacts).to_html
  end

  def payload_html
    Govspeak::Document.new(text, contacts: contacts).to_html
  end

private

  def contacts
    @contacts ||= begin
                    contact_content_ids = Govspeak::Document.new(text).extract_contact_content_ids
                    contacts = contact_content_ids.map do |id|
                      ContactsService.new.by_content_id(id)
                    end
                    contacts.compact
                  end
  end



end
