# frozen_string_literal: true

RSpec.feature "User orders documents" do
  scenario "User orders documents" do
    given_there_are_some_documents
    when_i_visit_the_index_page
    then_i_see_the_most_recently_updated_first
    when_i_toggle_the_last_updated_sort_order
    then_i_see_the_least_recently_updated_first
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
    expect(most_recent_index < least_recent_index)

    asc_updated_title = I18n.t('documents.index.search_results.headings.last_updated_asc')
    expect(page).to have_selector("[title='#{asc_updated_title}']")
  end

  def when_i_toggle_the_last_updated_sort_order
    click_on "Last updated"
  end

  def then_i_see_the_least_recently_updated_first
    most_recent_index = page.body.index(@most_recent.title)
    least_recent_index = page.body.index(@least_recent.title)
    expect(most_recent_index > least_recent_index)

    desc_updated_title = I18n.t('documents.index.search_results.headings.last_updated_desc')
    expect(page).to have_selector("[title='#{desc_updated_title}']")
  end
end
