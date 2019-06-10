# frozen_string_literal: true

RSpec.feature "Change schedule with requirements issues" do
  scenario do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    and_i_enter_invalid_date_fields
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_scheduled_edition
    datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, :scheduled, scheduled_publishing_datetime: datetime)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def and_i_enter_invalid_date_fields
    fill_in "schedule[date][day]", with: ""
    click_on "Save date"
  end

  def then_i_see_an_error_to_fix_the_issues
    expect(page).to have_content(
      I18n.t!("requirements.schedule_date.invalid.form_message"),
    )
  end
end
