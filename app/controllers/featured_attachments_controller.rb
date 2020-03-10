class FeaturedAttachmentsController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
  end
end
