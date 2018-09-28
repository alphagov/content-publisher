# frozen_string_literal: true

RSpec.feature "Create a document" do
  scenario do
    when_i_choose_a_format
    then_i_wont_be_able_to_choose_an_update_type_or_change_note

    when_i_visit_the_summary_page
    then_i_see_the_document_is_in_draft
    and_the_summary_page_does_not_display_change_note_and_update_type
  end

  def when_i_choose_a_format
    stub_any_publishing_api_put_content

    schema = DocumentTypeSchema.find("news_story")
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("news").label
    click_on "Continue"
    choose schema.label
    click_on "Continue"
  end

  def then_i_wont_be_able_to_choose_an_update_type_or_change_note
    expect(page).not_to have_selector("textarea[name='document[change_note]']")
    expect(page).not_to have_selector("input[name='document[update_type]']")
  end

  def when_i_visit_the_summary_page
    @document = Document.last
    visit document_path(@document)
  end

  def then_i_see_the_document_is_in_draft
    expect(page).to have_content("Draft")
  end

  def and_the_summary_page_does_not_display_change_note_and_update_type
    expect(page).not_to have_content I18n.t("documents.show.contents.items.update_type")
  end
end
