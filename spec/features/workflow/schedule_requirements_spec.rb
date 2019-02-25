# frozen_string_literal: true

RSpec.feature "Scheduling requirements" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule_publishing
    and_i_enter_invalid_date_fields
    and_i_click_save
    then_i_see_an_error_about_the_date_being_invalid
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule_publishing
    find(".govuk-details__summary-text", text: "Schedule publishing").click
  end

  def and_i_enter_invalid_date_fields
    fill_in "scheduled[day]", with: ""
    fill_in "scheduled[month]", with: ""
    fill_in "scheduled[year]", with: ""
  end

  def and_i_click_save
    click_on "Save"
  end

  def then_i_see_an_error_about_the_date_being_invalid
    expect(page).to have_content(
      I18n.t!("requirements.scheduled_datetime.invalid.form_message",
      field: "Date"),
    )
  end
end
