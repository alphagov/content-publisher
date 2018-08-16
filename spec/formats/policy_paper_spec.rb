# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Create a policy paper" do
  scenario "User creates a policy paper" do
    when_i_choose_this_document_type
    then_i_am_redirected_to_another_app
  end

  def when_i_choose_this_document_type
    visit "/"
    click_on I18n.t("documents.index.actions.new")

    choose SupertypeSchema.find("policy").label
    click_on I18n.t("new_document.choose_supertype.actions.continue")

    choose DocumentTypeSchema.find("policy_paper").label
    click_on I18n.t("new_document.choose_document_type.actions.continue")
  end

  def then_i_am_redirected_to_another_app
    expect(page.current_path).to eq("/government/admin/publications/new")
    expect(page).to have_content("You've been redirected")
  end
end
