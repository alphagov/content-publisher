# frozen_string_literal: true

RSpec.feature "Change proposed schedule" do
  scenario do
    given_there_is_an_edition_with_a_proposed_publish_time
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    then_i_see_the_proposed_time

    when_i_set_a_new_time
    then_i_see_the_new_proposed_time
  end

  def given_there_is_an_edition_with_a_proposed_publish_time
    @publish_time = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, proposed_publish_time: @publish_time)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def then_i_see_the_proposed_time
    expect(find_field("schedule[date][day]").value).to eq @publish_time.day.to_s
    expect(find_field("schedule[date][month]").value).to eq @publish_time.month.to_s
    expect(find_field("schedule[date][year]").value).to eq @publish_time.year.to_s
    expect(find_field("schedule[time]").value).to eq "10:00am"
  end

  def when_i_set_a_new_time
    @new_time = Time.current.advance(days: 2)
    fill_in "schedule[date][day]", with: @new_time.day
    fill_in "schedule[date][month]", with: @new_time.month
    fill_in "schedule[date][year]", with: @new_time.year
    select "11:00pm", from: "schedule[time]"
    click_on "Save date"
  end

  def then_i_see_the_new_proposed_time
    date = @new_time.strftime("%-d %B %Y")
    expect(page).to have_content("Proposed to publish at 11:00pm on #{date}")
  end
end
