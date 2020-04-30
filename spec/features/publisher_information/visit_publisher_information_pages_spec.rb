RSpec.feature "User can view the publisher information pages" do
  scenario do
    given_im_on_the_home_page
    when_i_click_on_the_publisher_updates_link_in_footer
    then_i_can_see_publisher_updates_page
    when_i_click_on_the_beta_capabilities_link_in_footer
    then_i_can_see_beta_capabilities_page
    when_i_click_on_the_how_to_use_publisher_link_in_footer
    then_i_can_see_how_to_use_publisher_page
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
    within(".govuk-footer") do
      click_on "What’s new in Content Publisher"
    end
  end

  def then_i_can_see_publisher_updates_page
    within("main h1") do
      expect(page).to have_content(I18n.t("publisher_information.publisher_updates.title"))
    end
  end

  def when_i_click_on_the_beta_capabilities_link_in_footer
    within(".govuk-footer") do
      click_on "What the Beta can and cannot do"
    end
  end

  def then_i_can_see_beta_capabilities_page
    within("main h1") do
      expect(page).to have_content(I18n.t("publisher_information.beta_capabilities.title"))
    end
  end

  def when_i_click_on_the_how_to_use_publisher_link_in_footer
    within(".govuk-footer") do
      click_on "How to use Content Publisher"
    end
  end

  def then_i_can_see_how_to_use_publisher_page
    within("main h1") do
      expect(page).to have_content(I18n.t("publisher_information.how_to_use_publisher.title"))
    end
  end

  def when_i_click_on_the_request_training_link_in_footer
    within(".govuk-footer") do
      click_on "Request Content Publisher training"
    end
  end

  def then_i_can_see_the_request_training_page
    within("main h1") do
      expect(page).to have_content(I18n.t("publisher_information.request_training.title"))
    end
  end

  def when_i_click_on_the_what_managing_editors_can_do_link_in_footer
    within(".govuk-footer") do
      click_on "What Managing Editors can do"
    end
  end

  alias :and_i_click_on_the_what_managing_editors_can_do_link_in_footer :when_i_click_on_the_what_managing_editors_can_do_link_in_footer

  def then_i_can_see_the_what_managing_editors_can_do_page
    within("main h1") do
      expect(page).to have_content(I18n.t("publisher_information.what_managing_editors_can_do.title"))
    end
  end

  def when_i_have_the_managing_editor_permission
    current_user.update_attribute(:permissions, [User::MANAGING_EDITOR_PERMISSION])
  end

  def and_i_see_i_am_not_a_managing_editor
    expect(page).to have_content(I18n.t("publisher_information.what_managing_editors_can_do.user_status.without_managing_editor_status"))
  end

  def and_i_see_i_am_a_managing_editor
    expect(page).to have_content(I18n.t("publisher_information.what_managing_editors_can_do.user_status.with_managing_editor_status"))
  end
end
