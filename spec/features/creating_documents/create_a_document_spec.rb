# frozen_string_literal: true

RSpec.feature "Create a document" do
  scenario "User creates a document" do
    when_i_choose_a_format
    then_i_wont_be_able_to_choose_an_update_type_or_change_note

    when_i_visit_the_summary_page
    then_i_see_the_document_is_in_draft
    and_the_update_type_is_major
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

  def and_the_update_type_is_major
    expect(page).to have_content(I18n.t("documents.edit.update_type.major_name"))
  end
end
