# frozen_string_literal: true

class GovspeakDocument::Options
  attr_reader :text, :edition

  def initialize(text, edition)
    @text = text
    @edition = edition
  end

  def to_h
    { contacts: contacts }
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
