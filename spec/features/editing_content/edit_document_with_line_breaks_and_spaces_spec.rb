# frozen_string_literal: true

RSpec.feature "Edit a document with fields containing line breaks and spaces" do
  scenario do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_title_with_leading_and_trailing_line_breaks_and_spaces
    then_i_see_the_document_is_saved
    and_the_title_no_longer_has_leading_and_trailing_line_breaks_and_spaces
  end

  def given_there_is_a_document
    create(:document, title: "Existing title")
  end

  def when_i_go_to_edit_the_document
    visit document_path(Document.last)
    expect(page).to have_content("Existing title")
    click_on "Change Content"
  end

  def and_i_fill_in_the_title_with_leading_and_trailing_line_breaks_and_spaces
    fill_in "document[title]", with: " \r\nEdited title \r\n\n"
    stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Save"
  end

  def then_i_see_the_document_is_saved
    expect(page).to have_content("Edited title")

    within find(".app-timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.updated_content")
    end
  end

  def and_the_title_no_longer_has_leading_and_trailing_line_breaks_and_spaces
    expect(Document.last.title).to eq("Edited title")
  end
end
