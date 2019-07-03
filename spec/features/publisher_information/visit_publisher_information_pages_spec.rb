# frozen_string_literal: true

RSpec.feature "User can view the publisher information pages" do
  scenario do
    given_im_on_the_home_page
    when_i_click_on_the_publisher_updates_link_in_footer
    then_i_can_see_publisher_updates_page
    when_i_click_on_the_beta_capabilities_link_in_footer
    then_i_can_see_beta_capabilities_page
    when_i_click_on_the_how_to_use_publisher_link_in_footer
    then_i_can_see_how_to_use_publisher_page
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
    within(".page-title") do
      expect(page).to have_content(I18n.t("publisher_information.publisher_updates.title"))
    end
  end

  def when_i_click_on_the_beta_capabilities_link_in_footer
    within(".govuk-footer") do
      click_on "What the Beta can and cannot do"
    end
  end

  def then_i_can_see_beta_capabilities_page
    within(".page-title") do
      expect(page).to have_content(I18n.t("publisher_information.beta_capabilities.title"))
    end
  end

  def when_i_click_on_the_how_to_use_publisher_link_in_footer
    within(".govuk-footer") do
      click_on "How to use Content Publisher"
    end
  end

  def then_i_can_see_how_to_use_publisher_page
    within(".page-title") do
      expect(page).to have_content(I18n.t("publisher_information.how_to_use_publisher.title"))
    end
  end
end
