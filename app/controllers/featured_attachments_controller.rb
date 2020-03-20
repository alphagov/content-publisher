class FeaturedAttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports featured attachments") do
      @edition.document_type.attachments.featured?
    end
  end

  def reorder
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports featured attachments") do
      @edition.document_type.attachments.featured?
    end
  end

  def update_order
    result = FeaturedAttachments::UpdateOrderInteractor.call(params: params, user: current_user)
    edition = result.edition
    redirect_to featured_attachments_path(edition.document)
  end
end
