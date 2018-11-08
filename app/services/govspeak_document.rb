# frozen_string_literal: true

class GovspeakDocument
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def to_html
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
