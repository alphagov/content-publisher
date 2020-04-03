module FileAttachmentHelper
  def file_attachment_preview_url(attachment_revision, document)
    service = PreviewAuthBypass.new(document)
    params = { token: service.preview_token }.to_query
    attachment_revision.asset_url + "?" + params
  end

  def file_attachment_attributes(attachment_revision, edition)
    attributes = {
      id: attachment_revision.filename,
      title: attachment_revision.title,
      filename: attachment_revision.filename,
      content_type: attachment_revision.content_type,
      file_size: attachment_revision.byte_size,
      number_of_pages: attachment_revision.number_of_pages,
      url: preview_file_attachment_path(edition.document, attachment_revision.file_attachment),
    }

    if edition.document_type.attachments.featured?
      attributes[:isbn] = attachment_revision.isbn
      attributes[:unique_reference] = attachment_revision.unique_reference

      if attachment_revision.command_paper?
        attributes[:unnumbered_command_paper] = true if attachment_revision.paper_number.blank?
        attributes[:command_paper_number] = attachment_revision.paper_number.presence
      end

      if attachment_revision.act_paper?
        attributes[:unnumbered_hoc_paper] = true if attachment_revision.paper_number.blank?
        attributes[:hoc_paper_number] = attachment_revision.paper_number.presence
      end
    end

    attributes.compact
  end
end
