# frozen_string_literal: true

RSpec.feature "Clear scheduled publishing datetime" do
  scenario do
    given_there_is_an_edition_with_a_set_scheduled_publishing_datetime
    when_i_visit_the_summary_page
    and_i_click_change_date
    then_i_see_the_existing_scheduled_publishing_date_and_time
    when_i_click_clear_date
    then_the_content_no_longer_has_a_scheduled_publishing_date_and_time
  end

  def given_there_is_an_edition_with_a_set_scheduled_publishing_datetime
    @datetime = Time.zone.now.advance(days: 2).midday
    @scheduled_date = @datetime.strftime("%-d %B %Y")
    @edition = create(:edition, scheduled_publishing_datetime: @datetime)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
    expect(page).to have_content("Proposed to publish at 12:00pm on #{@scheduled_date}")
  end

  def and_i_click_change_date
    click_on "Change date"
  end

  def then_i_see_the_existing_scheduled_publishing_date_and_time
    expect(page).to have_selector(
      "[@name='schedule[day]'][@value='#{@datetime.day}']",
    )
    expect(page).to have_selector(
      "[@name='schedule[month]'][@value='#{@datetime.month}']",
    )
    expect(page).to have_selector(
      "[@name='schedule[year]'][@value='#{@datetime.year}']",
    )
    expect(page).to have_field("schedule[time]", text: "12:00pm")
  end

  def when_i_click_clear_date
    click_on "Clear schedule date"
  end

  def then_the_content_no_longer_has_a_scheduled_publishing_date_and_time
    scheduled_date = @datetime.strftime("%-d %B %Y")
    expect(page).to_not have_content("Proposed to publish at 12:00pm on #{scheduled_date}")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.scheduled_publishing_datetime_cleared")
    end
  end
end
