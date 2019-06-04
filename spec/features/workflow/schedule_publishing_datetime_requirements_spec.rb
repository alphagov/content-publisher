# frozen_string_literal: true

RSpec.feature "Scheduled publishing datetime requirements" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_enter_invalid_date_fields
    and_i_click_continue
    then_i_see_an_error_about_the_date_being_invalid
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_enter_invalid_date_fields
    fill_in "schedule[date][day]", with: ""
    fill_in "schedule[date][month]", with: ""
    fill_in "schedule[date][year]", with: ""
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_an_error_about_the_date_being_invalid
    expect(page).to have_content(
      I18n.t!("requirements.scheduled_date.invalid.form_message"),
    )
  end
end
