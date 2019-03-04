# frozen_string_literal: true

RSpec.feature "Index ordering" do
  scenario do
    given_there_are_some_editions
    when_i_visit_the_index_page
    then_i_see_the_most_recently_updated_first
    when_i_toggle_the_last_updated_sort_order
    then_i_see_the_least_recently_updated_first
    when_i_apply_a_filter
    then_i_see_the_least_recently_ordering_is_maintained
  end

  def given_there_are_some_editions
    @most_recent = create(:edition,
                          title: "Most recent",
                          last_edited_at: 1.minute.ago,
                          created_by: current_user)
    @least_recent = create(:edition,
                           title: "Least recent",
                           last_edited_at: 2.minutes.ago,
                           created_by: current_user)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_see_the_most_recently_updated_first
    most_recent_index = page.body.index(@most_recent.title)
    least_recent_index = page.body.index(@least_recent.title)
    expect(most_recent_index).to be < least_recent_index

    expect(page).to have_selector(".app-table__sort-link--descending", text: "Last updated")
  end

  def when_i_toggle_the_last_updated_sort_order
    click_on "Last updated"
  end

  def then_i_see_the_least_recently_updated_first
    most_recent_index = page.body.index(@most_recent.title)
    least_recent_index = page.body.index(@least_recent.title)
    expect(least_recent_index).to be < most_recent_index

    expect(page).to have_selector(".app-table__sort-link--ascending", text: "Last updated")
  end

  def when_i_apply_a_filter
    fill_in "title_or_url", with: "recent"
    click_on "Filter"
  end

  def then_i_see_the_least_recently_ordering_is_maintained
    then_i_see_the_least_recently_updated_first
  end
end
