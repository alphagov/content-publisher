# frozen_string_literal: true

RSpec.feature "Backdate content" do
  scenario "first edition" do
    given_there_is_a_document_with_a_first_edition
    when_i_visit_the_summary_page
    and_i_click_to_backdate_the_content
    and_i_enter_a_date_to_backdate_the_content_to
    and_i_click_save
    then_i_see_the_date_the_content_was_backdated_to
  end

  scenario "subsequent edition" do
    given_there_is_a_document_with_a_second_edition
    when_i_visit_the_summary_page
    then_i_cannot_see_a_backdate_section
  end

  scenario "published edition" do
    given_there_is_a_published_first_edition
    when_i_visit_the_summary_page
    then_i_cannot_see_a_backdate_section
  end

  def given_there_is_a_document_with_a_first_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_to_backdate_the_content
    click_on "Edit Backdate"
  end

  def and_i_enter_a_date_to_backdate_the_content_to
    fill_in "backdate[date][day]", with: "1"
    fill_in "backdate[date][month]", with: "1"
    fill_in "backdate[date][year]", with: "2019"
  end

  def and_i_click_save
    click_on "Save"
  end

  def then_i_see_the_date_the_content_was_backdated_to
    expect(page).to have_content("1 January 2019")
  end

  def given_there_is_a_document_with_a_second_edition
    @edition = create(:edition, number: 2)
  end

  def then_i_cannot_see_a_backdate_section
    expect(page).not_to have_content(
      I18n.t!("documents.show.content_settings.backdate.title"),
    )
    expect(page).not_to have_content("Edit Backdate")
  end

  def given_there_is_a_published_first_edition
    @edition = create(:edition, :published, number: 1)
  end
end
