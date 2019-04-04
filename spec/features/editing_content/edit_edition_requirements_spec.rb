# frozen_string_literal: true

RSpec.feature "Edit an edition with requirements issues" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_edit_document_page
    and_submit_a_request_with_requirement_issues
    then_i_should_see_an_error_to_fix_the_issues
    and_see_my_previous_submission
  end

  def given_there_is_an_edition
    @edition = create(:edition, title: "Valid title")
  end

  def when_i_visit_the_edit_document_page
    visit edit_document_path(@edition.document)
  end

  def and_submit_a_request_with_requirement_issues
    fill_in "revision[title]", with: ""
    click_on "Save"
  end

  def then_i_should_see_an_error_to_fix_the_issues
    expect(page).to have_content(I18n.t!("requirements.title.blank.form_message"))
  end

  def and_see_my_previous_submission
    expect(page).to have_field("revision[title]", with: "")
  end
end
