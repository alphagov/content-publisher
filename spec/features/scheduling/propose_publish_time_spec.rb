# frozen_string_literal: true

RSpec.feature "Propose a publish time" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2019-06-13 11:00") { example.run }
  end

  scenario "save proposed time" do
    given_there_is_an_edition
    when_i_go_to_propose_a_publish_time
    and_i_use_the_default_time
    and_i_select_save_proposed_time
    then_i_see_there_is_a_proposed_publish_time
  end

  scenario "schedule to publish" do
    given_there_is_an_edition
    when_i_go_to_propose_a_publish_time
    and_i_use_the_default_time
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

  def and_i_use_the_default_time
    expect(page).to have_field("schedule[date][day]", with: "14")
    expect(page).to have_field("schedule[date][month]", with: "6")
    expect(page).to have_field("schedule[date][year]", with: "2019")
    expect(page).to have_field("schedule[time]", with: "9:00am")
  end

  def and_i_select_save_proposed_time
    choose "Save proposed date and time"
    click_on "Continue"
  end

  def then_i_see_there_is_a_proposed_publish_time
    expect(page)
      .to have_content(I18n.t!("documents.show.scheduling.notice.proposed",
                               time: "9:00am",
                               date: "14 June 2019"))
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
                               time: "9:00am",
                               date: "14 June 2019"))
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
