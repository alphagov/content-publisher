# frozen_string_literal: true

RSpec.feature "User orders documents" do
  scenario do
    given_there_are_some_documents
    when_i_visit_the_index_page
    then_i_see_the_most_recently_updated_first
    when_i_toggle_the_last_updated_sort_order
    then_i_see_the_least_recently_updated_first
    when_i_apply_a_filter
    then_i_see_the_least_recently_ordering_is_maintained
  end

  def given_there_are_some_documents
    @most_recent = create(:document, title: "Most recent", updated_at: 1.minute.ago)
    @least_recent = create(:document, title: "Least recent", updated_at: 2.minutes.ago)
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
