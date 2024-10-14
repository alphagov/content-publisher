class RemoveController < ApplicationController
  def remove
    @edition = Edition.find_last(document: params[:document]) # find last
    puts(@edition)

    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
  end
end
