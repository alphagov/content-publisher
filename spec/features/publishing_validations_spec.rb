# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Publish validations" do
  scenario "A document is validated" do
    given_there_is_a_document_with_not_enough_info
    when_i_visit_the_document_page
    then_i_see_the_warnings
    when_i_fix_some_warnings
    then_i_see_fewer_warnings
  end

  def given_there_is_a_document_with_not_enough_info
    @document = create(:document, :with_body_in_schema)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_the_warnings
    expect(page).to have_content "The title needs to be at least 10 characters long"
    expect(page).to have_content "The summary needs to be at least 10 characters long"
    expect(page).to have_content "Body needs to be at least 10 characters long"
  end

  def when_i_fix_some_warnings
    # Clicking save will make a request, but we don't care about the
    # particulars, which are tested in the feature test of the "edit" flow
    stub_any_publishing_api_put_content
    base_path = "#{@document.document_type_schema.path_prefix}/a-nice-title-of-considerable-length"
    publishing_api_has_lookups(base_path => nil)
    click_on "Edit document"
    fill_in "document[title]", with: "A nice title of considerable length"
    fill_in "document[contents][body]", with: "A very long body text."
    click_on "Save"
  end

  def then_i_see_fewer_warnings
    expect(page).not_to have_content "The title needs to be at least 10 characters long"
    expect(page).not_to have_content "Body needs to be at least 10 characters long"

    expect(page).to have_content "The summary needs to be at least 10 characters long"
  end
end
