# frozen_string_literal: true

RSpec.feature "Edit a document with requirements issues" do
  scenario do
    given_there_is_a_document_with_issues
    when_i_visit_the_edit_document_page_and_save
    then_i_should_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document_with_issues
    @edition = create(:edition, title: "")
  end

  def when_i_visit_the_edit_document_page_and_save
    visit edit_document_path(@edition.document)
    click_on "Save"
  end

  def then_i_should_see_an_error_to_fix_the_issues
    expect(page).to have_content(I18n.t!("requirements.title.blank.form_message"))
  end
end
