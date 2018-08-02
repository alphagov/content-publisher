# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Shows a preview of the URL", type: :feature, js: true do
  scenario "when a user edits a document" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_title
    then_i_see_a_preview_of_the_url_on_govuk
  end

  def given_there_is_a_document
    @document = create(:document)
    @document_path_prefix = @document.document_type_schema.path_prefix
  end

  def when_i_go_to_edit_the_document
    visit document_path(@document)
    click_on "Edit document"
  end

  def and_i_fill_in_the_title
    @request = publishing_api_has_lookups("#{@document_path_prefix}/a-great-title": nil)
    fill_in("document[title]", with: "A great title")
    page.find("body").click
  end

  def then_i_see_a_preview_of_the_url_on_govuk
    expect(page).to have_content "www.gov.uk#{@document_path_prefix}/a-great-title"
    expect(@request).to have_been_requested
  end
end
