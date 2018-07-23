# frozen_string_literal: true

require "spec_helper"

RSpec.describe "User is not sure if the content belongs on GOV.UK", type: :feature do
  scenario "User selects 'I’m not sure this should be on GOV.UK'" do
    when_i_click_on_create_a_document
    and_i_choose_i_am_not_sure_if_it_belongs_on_govuk
    then_i_see_the_guidance
  end

  def when_i_click_on_create_a_document
    visit "/"
    click_on "New document"
  end

  def and_i_choose_i_am_not_sure_if_it_belongs_on_govuk
    choose "I'm not sure this should be on GOV.UK"
    click_on "Continue"
  end

  def then_i_see_the_guidance
    expect(page).to have_title "What to publish on GOV.UK"
  end
end
