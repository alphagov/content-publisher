RSpec.feature "User can navigate through a documents history" do
  scenario do
    given_there_is_an_edition_with_extensive_document_history
    when_i_visit_the_summary_page
    and_click_on_document_history
    then_i_see_a_list_of_timeline_entries

    when_i_click_to_go_to_the_next_page
    then_i_see_some_more_timeline_entries
  end

  def given_there_is_an_edition_with_extensive_document_history
    @edition = create(:edition)
    create(:timeline_entry, edition: @edition)
    create_list(:timeline_entry, 50, entry_type: "updated_content", edition: @edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_click_on_document_history
    click_on "Document history"
  end

  def then_i_see_a_list_of_timeline_entries
    expect(page).to have_content(I18n.t!("documents.history.entry_types.updated_content"), count: 50)
                .and have_content(I18n.t!("documents.history.page_info", page: 2, pages: 2))
                .and have_link("Next page")
  end

  def when_i_click_to_go_to_the_next_page
    click_on "Next page"
  end

  def then_i_see_some_more_timeline_entries
    expect(page).to have_content(I18n.t!("documents.history.entry_types.created"), count: 1)
                .and have_content(I18n.t!("documents.history.page_info", page: 1, pages: 2))
                .and have_link("Previous page")
  end
end
