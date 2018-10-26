# frozen_string_literal: true

RSpec.feature "Viewing debug information" do
  scenario do
    given_there_is_a_document
    when_i_dont_have_the_debug_permission
    and_i_visit_the_debug_page
    then_i_see_an_error_page
    when_im_given_debug_permission
    and_i_visit_the_debug_page
    then_i_see_the_debug_page
  end

  def given_there_is_a_document
    create :document
  end

  def and_i_visit_the_debug_page
    visit debug_document_path(Document.last)
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
      "Internal metadata for ‘#{Document.last.title_or_fallback}’",
    )
  end
end
