# frozen_string_literal: true

RSpec.feature "Propose and schedule with requirements issues" do
  scenario do
    given_there_is_an_edition_with_issues
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_select_schedule_to_publish
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition_with_issues
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_select_schedule_to_publish
    choose "Schedule to publish"
    click_on "Continue"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end
end
