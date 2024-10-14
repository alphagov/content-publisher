class RemoveController < ApplicationController
  def remove
    @edition = Edition.find_current(document: params[:document]) # find current
    puts(@edition.state)

    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
  end
end
