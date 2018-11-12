# frozen_string_literal: true

RSpec.feature "Viewing documentation" do
  scenario do
    when_i_dont_have_the_debug_permission
    and_i_visit_the_documentation_page
    then_i_see_an_error_page
    when_im_given_debug_permission
    and_i_visit_the_documentation_page
    then_i_see_the_documentation_page
  end

  def when_i_dont_have_the_debug_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::DEBUG_PERMISSION])
  end

  def and_i_visit_the_documentation_page
    visit "/documentation"
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

  def then_i_see_the_documentation_page
    expect(page).to have_content(I18n.t!("documentation.index.title"))
  end
end
