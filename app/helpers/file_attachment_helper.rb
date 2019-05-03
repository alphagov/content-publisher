# frozen_string_literal: true

module FileAttachmentHelper
  def file_attachment_in_app_attributes(file_attachment)
    file_attachment_attributes(file_attachment).merge(
      url: "#",
    )
  end

  def file_attachment_payload_attributes(file_attachment)
    file_attachment_attributes(file_attachment).merge(
      url: file_attachment.asset_url("file"),
    )
  end

private

  def file_attachment_attributes(file_attachment)
    {
      id: file_attachment.filename,
      title: file_attachment.title,
      filename: file_attachment.filename,
      content_type: file_attachment.content_type,
      file_size: file_attachment.byte_size,
      number_of_pages: file_attachment.number_of_pages,
    }
  end
end
