# frozen_string_literal: true

RSpec.feature "Propose publish time and schedule" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.parse("2019-06-17")) { example.run }
  end

  scenario do
    given_there_is_an_edition
    when_i_go_to_propose_a_publish_time
    and_i_enter_a_time
    and_i_select_schedule_to_publish
    then_i_see_the_schedule_review_form
    when_i_submit_a_review_option
    then_i_see_the_edition_is_scheduled
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_go_to_propose_a_publish_time
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_i_enter_a_time
    fill_in "schedule[date][day]", with: "20"
    fill_in "schedule[date][month]", with: "8"
    fill_in "schedule[date][year]", with: "2019"
    fill_in "schedule[time]", with: "3:30pm"
  end

  def and_i_select_schedule_to_publish
    choose "Schedule to publish"
    click_on "Continue"
  end

  def then_i_see_the_schedule_review_form
    expect(page)
      .to have_content(I18n.t!("schedule.new.title"))
    expect(page)
      .to have_content(I18n.t!("schedule.new.hint_text",
                               time: "3:30pm",
                               date: "20 August 2019"))
  end

  def when_i_submit_a_review_option
    @request = stub_default_publishing_api_put_intent

    choose I18n.t!("schedule.new.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_is_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))
  end
end
