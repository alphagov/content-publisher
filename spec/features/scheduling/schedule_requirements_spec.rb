# frozen_string_literal: true

RSpec.feature "Schedule an edition with requirements issues" do
  scenario do
    given_there_is_an_edition_with_issues
    when_i_visit_the_summary_page
    and_i_click_schedule
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition_with_issues
    @edition = create(:edition, :schedulable)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_schedule
    click_on "Schedule"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end
end
