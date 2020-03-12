class FeaturedAttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports featured attachments") do
      @edition.document_type.attachments.featured?
    end
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:attachment_id])
  end
end
