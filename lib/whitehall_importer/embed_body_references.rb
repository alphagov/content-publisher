# frozen_string_literal: true

module WhitehallImporter
  class EmbedBodyReferences
    attr_reader :body, :contacts

    def self.call(*args)
      new(*args).call
    end

    def initialize(body:, contacts: [])
      @body = body
      @contacts = contacts
    end

    def call
      embed_contacts(body, contacts)
    end

  private

    def embed_contacts(body, contacts)
      body&.gsub(/\[Contact:\s*(\d*)\s*\]/) do
        id = Regexp.last_match[1].to_i
        embed = contacts.select { |x| x["id"] == id }.first["content_id"]
        "[Contact:#{embed}]"
      end
    end
  end
end
