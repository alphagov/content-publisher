# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Shows a preview of the URL", type: :feature, js: true do
  # TODO: Flaky tests yayyyy (some randomly generated paths create errors)
  scenario "when a user edits the title of a document" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_title
    then_i_see_a_preview_of_the_url_on_govuk
  end

  scenario "when the user does not edit the title" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_interact_with_the_title_but_leave_it_unedited
    then_i_see_the_path_preview_unchanged
  end

  def given_there_is_a_document
    @document = create(:document)
    @document_path_prefix = @document.document_type_schema.path_prefix
    @document_base_path = @document.base_path
  end

  def when_i_go_to_edit_the_document
    visit document_path(@document)
    click_on "Edit document"
  end

  def and_i_interact_with_the_title_but_leave_it_unedited
    @publishing_api_call_with_content = publishing_api_has_lookups(
      "#{@document_base_path}": @document.content_id,
      "#{@document_base_path}-1": nil,
    )
    page.find("#document-title-id").click
    page.find("body").click
  end

  def and_i_fill_in_the_title
    @publishing_api_call_without_content = publishing_api_has_lookups("#{@document_path_prefix}/a-great-title": nil)
    fill_in("document[title]", with: "A great title")
    page.find("body").click
  end

  def then_i_see_a_preview_of_the_url_on_govuk
    expect(page).to have_content "www.gov.uk#{@document_path_prefix}/a-great-title"
    expect(@publishing_api_call_without_content).to have_been_requested.times(2)
  end

  def then_i_see_the_path_preview_unchanged
    expect(page).to have_content "www.gov.uk#{@document_base_path}"
    expect(page).to_not have_content "www.gov.uk#{@document_base_path}-1"
    expect(@publishing_api_call_with_content).to have_been_requested.times(4)
  end
end
