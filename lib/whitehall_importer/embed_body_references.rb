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
      body_with_embeds = embed_images(body_with_embeds, images)
      body_with_embeds = embed_attachments(body_with_embeds, attachments)
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

    def embed_images(body, images)
      body&.gsub(/!!(\d+)/) do
        whitehall_image_index = Regexp.last_match[1].to_i
        image_name = images[whitehall_image_index - 1]
        image_name.present? ? "[Image:#{image_name}]" : ""
      end
    end

    def embed_attachments(body, attachments)
      body&.gsub(/!@(\d+)/) do
        whitehall_attachment_index = Regexp.last_match[1].to_i
        attachment_name = attachments[whitehall_attachment_index - 1]
        attachment_name.present? ? "[Attachment:#{attachment_name}]" : ""
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
