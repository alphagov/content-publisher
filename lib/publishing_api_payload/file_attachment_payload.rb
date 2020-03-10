class PublishingApiPayload::FileAttachmentPayload
  include Rails.application.routes.url_helpers
  include FileAttachmentHelper

  attr_reader :attachment, :document

  def initialize(attachment, document)
    @attachment = attachment
    @document = document
  end

  def payload
    payload = {
      attachment_type: "file",
      locale: document.locale,
      url: attachment.asset_url,
    }

    file_attachment_attributes(attachment, document).merge!(payload)
  end
end
