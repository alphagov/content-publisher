class FeaturedAttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports featured attachments") do
      @edition.document_type.attachments.featured?
    end
  end
end
