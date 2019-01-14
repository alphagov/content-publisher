# frozen_string_literal: true

RSpec.feature "Viewing debug information" do
  scenario do
    given_there_is_an_edition_with_revisions
    when_i_dont_have_the_debug_permission
    and_i_visit_the_debug_page
    then_i_see_an_error_page
    when_im_given_debug_permission
    and_i_visit_the_debug_page
    then_i_see_the_debug_page
    and_i_can_paginate_to_the_next_page
  end

  def given_there_is_an_edition_with_revisions
    @edition = create(:versioned_edition)
    revisions = create_list(:versioned_revision, 25, document: @edition.document)
    @edition.update!(revision: revisions.last)
  end

  def and_i_visit_the_debug_page
    visit versioned_debug_document_path(@edition.document)
  end

  def when_i_dont_have_the_debug_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::DEBUG_PERMISSION])
  end

  def then_i_see_an_error_page
    expect(page).to have_content(
      "Sorry, you don't seem to have the #{User::DEBUG_PERMISSION} permission for this app",
    )
  end

  def when_im_given_debug_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::DEBUG_PERMISSION])
  end

  def then_i_see_the_debug_page
    expect(page).to have_content(
      "Revision history for ‘#{@edition.title_or_fallback}’",
    )
  end

  def and_i_can_paginate_to_the_next_page
    click_on "Next page"
    expect(page).to have_content("Revision 1")
  end
end
