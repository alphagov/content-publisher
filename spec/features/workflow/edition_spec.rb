# frozen_string_literal: true

RSpec.feature "Editions" do
  scenario do
    given_there_is_a_published_document
    when_i_visit_the_document_page
    then_i_see_it_is_the_first_edition

    when_i_click_to_create_a_new_edition
    then_i_see_i_am_editing_a_new_edition

    when_i_edit_the_new_edition
    then_i_see_there_is_a_new_edition
  end

  def given_there_is_a_published_document
    @document = create(:document, :published, update_type: "major", change_note: "First edition.")
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_it_is_the_first_edition
    expect(page).to have_content(I18n.t("documents.show.contents.update_type.#{@document.update_type}"))
    expect(page).to have_content(@document.change_note)
  end

  def when_i_click_to_create_a_new_edition
    stub_any_publishing_api_put_content
    click_on "Create new edition"
  end

  def then_i_see_i_am_editing_a_new_edition
    expect(find_field("document[change_note]").value).to be_empty
    expect(find_field(I18n.t("documents.edit.update_type.major_name"))).to be_checked
  end

  def when_i_edit_the_new_edition
    fill_in "document[change_note]", with: "I made a change"
    choose I18n.t("documents.edit.update_type.minor_name")
    click_on "Save"
  end

  def then_i_see_there_is_a_new_edition
    expect(page).to have_content(I18n.t("documents.show.contents.update_type.minor"))
    expect(page).to have_content("I made a change")
  end
end
