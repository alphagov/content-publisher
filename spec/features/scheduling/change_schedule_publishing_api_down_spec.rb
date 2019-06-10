# frozen_string_literal: true

RSpec.feature "Change schedule when Publishing API is down" do
  scenario do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_the_publishing_api_is_down
    and_i_click_on_change_date
    and_i_set_a_new_schedule_datetime
    then_i_see_an_error_message
  end

  def given_there_is_a_scheduled_edition
    datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, :scheduled, scheduled_publishing_datetime: datetime)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def and_i_set_a_new_schedule_datetime
    new_datetime = Time.current.advance(days: 2)
    fill_in "schedule[date][day]", with: new_datetime.day
    click_on "Save date"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.schedule_error.title"))
  end
end
