# frozen_string_literal: true

RSpec.feature "Backdating requirements" do
  scenario do
    given_there_is_a_document_with_a_first_edition
    when_i_visit_the_summary_page
    and_i_click_to_backdate_the_content
    and_i_click_save
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document_with_a_first_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_to_backdate_the_content
    click_on "Change Backdate"
  end

  def and_i_click_save
    click_on "Save"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t!("requirements.backdate_date.invalid.form_message"),
      )
    end
  end
end
