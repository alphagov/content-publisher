# frozen_string_literal: true

RSpec.feature "Clear proposed publish time" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.parse("2019-06-13 11:00")) { example.run }
  end

  scenario do
    given_there_is_an_edition_with_a_proposed_publish_time
    when_i_visit_the_summary_page
    then_i_see_the_proposed_time
    when_i_go_to_change_the_date
    and_i_click_clear_schedule_date
    then_i_see_the_proposed_time_is_cleared
  end

  def given_there_is_an_edition_with_a_proposed_publish_time
    publish_time = Time.zone.parse("2019-06-15 12:00")
    @edition = create(:edition, proposed_publish_time: publish_time)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_the_proposed_time
    @proposed_content = I18n.t!("documents.show.proposed_scheduling_notice.title",
                                time: "12:00pm",
                                date: "15 June 2019")
    expect(page).to have_content(@proposed_content)
  end

  def when_i_go_to_change_the_date
    click_on "Change date"
  end

  def and_i_click_clear_schedule_date
    click_on "Clear schedule date"
  end

  def then_i_see_the_proposed_time_is_cleared
    expect(page).not_to have_content(@proposed_content)
  end
end
