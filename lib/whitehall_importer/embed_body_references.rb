# frozen_string_literal: true

module WhitehallImporter
  class EmbedBodyReferences
    attr_reader :body, :contacts, :images, :attachments

    def self.call(*args)
      new(*args).call
    end

    def initialize(body:, contacts: [], images: [], attachments: [])
      @body = body
      @contacts = contacts
      @images = images
      @attachments = attachments
    end

    def call
      body_with_embeds = embed_contacts(body, contacts)
      body_with_embeds = embed_files(body_with_embeds,
                                     files: images,
                                     old_pattern: "!!",
                                     new_pattern: "Image")
      body_with_embeds = embed_files(body_with_embeds,
                                     files: attachments,
                                     old_pattern: "!@",
                                     new_pattern: "Attachment")
      body_with_embeds = embed_inline_attachments(body_with_embeds, attachments)
      body_with_embeds
    end

  private

    def embed_contacts(body, contacts)
      body&.gsub(/\[Contact:\s*(\d*)\s*\]/) do
        id = Regexp.last_match[1].to_i
        embed = contacts.select { |x| x["id"] == id }.first["content_id"]
        "[Contact:#{embed}]"
      end
    end

    def embed_files(body, files:, old_pattern:, new_pattern:)
      body&.gsub(/(\A|\n\n|\r\n\r\n|\n|\r\n)#{old_pattern}(\d+)/) do
        prefix = Regexp.last_match[1]
        file_index = Regexp.last_match[2].to_i
        file_name = files[file_index - 1]
        prefix = prefix * 2 if ["\r\n", "\n"].include?(prefix)
        "#{prefix}[#{new_pattern}:#{file_name}]" if file_name.present?
      end
    end

    def embed_inline_attachments(body, attachments)
      body&.gsub(/\[InlineAttachment:(\d+)\s*\]/) do
        whitehall_attachment_index = Regexp.last_match[1].to_i
        attachment_name = attachments[whitehall_attachment_index - 1]
        attachment_name.present? ? "[AttachmentLink:#{attachment_name}]" : ""
      end
    end
  end
end
