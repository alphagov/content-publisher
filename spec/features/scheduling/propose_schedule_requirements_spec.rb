# frozen_string_literal: true

RSpec.feature "Propose schedule with requirements issues" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_enter_invalid_date_fields
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_enter_invalid_date_fields
    fill_in "schedule[date][year]", with: ""
    click_on "Continue"
  end

  def then_i_see_an_error_to_fix_the_issues
    expect(page).to have_content(
      I18n.t!("requirements.schedule_date.invalid.form_message"),
    )
  end
end
