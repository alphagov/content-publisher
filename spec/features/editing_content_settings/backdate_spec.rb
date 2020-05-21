RSpec.feature "Backdate content" do
  scenario do
    given_there_is_a_document_with_a_first_edition
    when_i_visit_the_summary_page
    then_i_see_that_the_content_has_not_been_backdated

    when_i_click_to_backdate_the_content
    and_i_enter_a_date_to_backdate_the_content_to
    and_i_click_save
    then_i_see_the_content_has_been_backdated
    and_i_see_the_backdate_timeline_entry

    when_i_click_to_backdate_the_content
    and_i_click_clear_backdate
    then_i_see_the_content_is_no_longer_backdated
    and_i_see_the_cleared_backdate_timeline_entry
  end

  def given_there_is_a_document_with_a_first_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_that_the_content_has_not_been_backdated
    expect(page).to have_content(
      I18n.t!("documents.show.content_settings.backdate.no_backdate"),
    )
  end

  def when_i_click_to_backdate_the_content
    click_on "Document summary"
    click_on "Change Backdate"
  end

  def and_i_enter_a_date_to_backdate_the_content_to
    fill_in "backdate[date][day]", with: "1"
    fill_in "backdate[date][month]", with: "1"
    fill_in "backdate[date][year]", with: "2019"
  end

  def and_i_click_save
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Save"
  end

  def then_i_see_the_content_has_been_backdated
    expect(page).to have_content("1 January 2019")
    expect(page).not_to have_content(I18n.t!("documents.show.content_settings.backdate.no_backdate"))
  end

  def and_i_see_the_backdate_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.backdated",
                                         date: "01 January 2019"))
  end

  def and_i_click_clear_backdate
    click_on "Clear backdate"
  end

  def then_i_see_the_content_is_no_longer_backdated
    expect(page).to have_content(
      I18n.t!("documents.show.content_settings.backdate.no_backdate"),
    )
  end

  def and_i_see_the_cleared_backdate_timeline_entry
    click_on "Document history"
    expect(page).to have_content(
      I18n.t!("documents.history.entry_types.backdate_cleared"),
    )
  end
end
