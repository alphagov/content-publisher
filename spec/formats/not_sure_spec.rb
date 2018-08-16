# frozen_string_literal: true

require "spec_helper"

RSpec.feature "User is not sure about the supertype" do
  scenario "User selects the not sure option" do
    when_i_click_on_create_a_document
    and_i_choose_i_am_not_sure_if_it_belongs_on_govuk
    then_i_see_the_guidance
  end

  def when_i_click_on_create_a_document
    visit "/"
    click_on I18n.t("documents.index.actions.new")
  end

  def and_i_choose_i_am_not_sure_if_it_belongs_on_govuk
    choose SupertypeSchema.find("not-sure").label
    click_on I18n.t("new_document.choose_supertype.actions.continue")
  end

  def then_i_see_the_guidance
    title = I18n.t("new_document.guidance.title")
    expect(page).to have_title(title)
  end
end
