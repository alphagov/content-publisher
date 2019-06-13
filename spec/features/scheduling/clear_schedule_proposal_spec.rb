# frozen_string_literal: true

RSpec.feature "Clear schedule proposal" do
  scenario do
    given_there_is_an_edition_with_a_proposed_schedule
    when_i_visit_the_summary_page
    then_i_see_the_proposed_schedule
    when_i_click_change_date
    and_i_click_clear_date
    then_i_see_the_schedule_proposal_is_cleared
  end

  def given_there_is_an_edition_with_a_proposed_schedule
    @publish_time = Time.current.advance(days: 2).midday
    @scheduled_date = @publish_time.strftime("%-d %B %Y")
    @edition = create(:edition, proposed_publish_time: @publish_time)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_the_proposed_schedule
    expect(page).to have_content("Proposed to publish at 12:00pm on #{@scheduled_date}")
  end

  def when_i_click_change_date
    click_on "Change date"
  end

  def and_i_click_clear_date
    click_on "Clear schedule date"
  end

  def then_i_see_the_schedule_proposal_is_cleared
    expect(page).to_not have_content("Proposed to publish at 12:00pm on #{@scheduled_date}")
  end
end
