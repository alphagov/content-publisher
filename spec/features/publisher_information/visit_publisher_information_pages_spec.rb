RSpec.feature "User can view the publisher information pages" do
  scenario do
    given_im_on_the_home_page
    when_i_click_on_the_publisher_updates_link_in_footer
    then_i_can_see_publisher_updates_page
    when_i_click_on_the_beta_capabilities_link_in_footer
    then_i_can_see_beta_capabilities_page
    when_i_click_on_the_how_to_use_publisher_link_in_footer
    then_i_can_see_the_how_to_use_publisher_page
    when_i_click_on_the_request_training_link_in_footer
    then_i_can_see_the_request_training_page
    when_i_click_on_the_what_managing_editors_can_do_link_in_footer
    then_i_can_see_the_what_managing_editors_can_do_page
    and_i_see_i_am_not_a_managing_editor
    when_i_have_the_managing_editor_permission
    and_i_click_on_the_what_managing_editors_can_do_link_in_footer
    then_i_can_see_the_what_managing_editors_can_do_page
    and_i_see_i_am_a_managing_editor
  end

  def given_im_on_the_home_page
    visit root_path
  end

  def when_i_click_on_the_publisher_updates_link_in_footer
    click_footer_link("What’s new in Content Publisher")
  end

  def then_i_can_see_publisher_updates_page
    expect_page_to_have_h1(I18n.t("publisher_information.publisher_updates.title"))
  end

  def when_i_click_on_the_beta_capabilities_link_in_footer
    click_footer_link("What the Beta can and cannot do")
  end

  def then_i_can_see_beta_capabilities_page
    expect_page_to_have_h1(I18n.t("publisher_information.beta_capabilities.title"))
  end

  def when_i_click_on_the_how_to_use_publisher_link_in_footer
    click_footer_link("How to use Content Publisher")
  end

  def then_i_can_see_the_how_to_use_publisher_page
    expect_page_to_have_h1(I18n.t("publisher_information.how_to_use_publisher.title"))
  end

  def when_i_click_on_the_request_training_link_in_footer
    click_footer_link("Request Content Publisher training")
  end

  def then_i_can_see_the_request_training_page
    expect_page_to_have_h1(I18n.t("publisher_information.request_training.title"))
  end

  def when_i_click_on_the_what_managing_editors_can_do_link_in_footer
    click_footer_link("What Managing Editors can do")
  end

  alias_method :and_i_click_on_the_what_managing_editors_can_do_link_in_footer, :when_i_click_on_the_what_managing_editors_can_do_link_in_footer

  def then_i_can_see_the_what_managing_editors_can_do_page
    expect_page_to_have_h1(I18n.t("publisher_information.what_managing_editors_can_do.title"))
  end

  def when_i_have_the_managing_editor_permission
    current_user.update(permissions: [User::MANAGING_EDITOR_PERMISSION])
  end

  def and_i_see_i_am_not_a_managing_editor
    expect(page).to have_content(I18n.t("publisher_information.what_managing_editors_can_do.user_status.without_managing_editor_status"))
  end

  def and_i_see_i_am_a_managing_editor
    expect(page).to have_content(I18n.t("publisher_information.what_managing_editors_can_do.user_status.with_managing_editor_status"))
  end

  def click_footer_link(text)
    within(".govuk-footer") { click_on text }
  end

  def expect_page_to_have_h1(content)
    within("main h1") { expect(page).to have_content(content) }
  end
end
