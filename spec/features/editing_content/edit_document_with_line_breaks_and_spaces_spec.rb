# frozen_string_literal: true

RSpec.feature "Edit a document with fields containing line breaks and spaces" do
  scenario do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_title_with_leading_and_trailing_line_breaks_and_spaces
    and_i_fill_in_the_summary_with_leading_and_trailing_line_breaks_and_spaces
    then_i_see_the_document_is_saved
    and_the_title_no_longer_has_leading_and_trailing_line_breaks_and_spaces
    and_the_summary_no_longer_has_leading_and_trailing_line_breaks_and_spaces
  end

  def given_there_is_a_document
    @edition = create(:edition, title: "Existing title", summary: "Existing summary.")
  end

  def when_i_go_to_edit_the_document
    visit document_path(@edition.document)
    expect(page).to have_content("Existing title")
    click_on "Change Content"
  end

  def and_i_fill_in_the_title_with_leading_and_trailing_line_breaks_and_spaces
    fill_in "revision[title]", with: " \r\nEdited title \r\n\n"
  end

  def and_i_fill_in_the_summary_with_leading_and_trailing_line_breaks_and_spaces
    fill_in "revision[summary]", with: "\n\n \rEdited summary.\n\n \r"
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Save"
  end

  def then_i_see_the_document_is_saved
    expect(page).to have_content("Edited title")
    expect(page).to have_content("Edited summary.")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.updated_content")
    end
  end

  def and_the_title_no_longer_has_leading_and_trailing_line_breaks_and_spaces
    expect(@edition.reload.title).to eq("Edited title")
  end

  def and_the_summary_no_longer_has_leading_and_trailing_line_breaks_and_spaces
    expect(@edition.reload.summary).to eq("Edited summary.")
  end
end
