# frozen_string_literal: true

RSpec.feature "Change notes" do
  scenario "User updates change notes and update type" do
    given_there_is_a_previously_published_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_change_note_and_update_type

    then_the_summary_page_displays_change_note_and_update_type
    and_the_form_displays_the_change_note_and_update_type
    and_the_publishing_api_should_know_the_update_type_and_change_note

    when_i_publish_the_document
    then_the_change_note_and_update_type_should_be_cleared_for_the_next_edition
  end

  def given_there_is_a_previously_published_document
    @document = create(:document, has_live_version_on_govuk: true)
  end

  def when_i_go_to_edit_the_document
    visit edit_document_path(@document)
  end

  def and_i_fill_in_the_change_note_and_update_type
    @update_request = stub_any_publishing_api_put_content

    fill_in "document[change_note]", with: "Updated banana pricing"
    choose I18n.t("documents.edit.update_type.minor_name")

    click_on "Save"
  end

  def then_the_summary_page_displays_change_note_and_update_type
    expect(page).to have_content "Updated banana pricing"
  end

  def and_the_form_displays_the_change_note_and_update_type
    visit edit_document_path(@document)
    expect(find("textarea[name='document[change_note]']")).to have_text "Updated banana pricing"
    expect(find("input[name='document[update_type]'][value='minor']")).to be_checked
  end

  def and_the_publishing_api_should_know_the_update_type_and_change_note
    expect(
      @update_request.with { |req|
        expect(JSON.parse(req.body)["update_type"]).to eq("minor")
        expect(JSON.parse(req.body)["change_note"]).to eq("Updated banana pricing")
      },
    ).to have_been_requested
  end

  def when_i_publish_the_document
    visit publish_document_path(@document)

    # We don't care about what kind of request is done here, this is tested in
    # the document editing feature test.
    stub_any_publishing_api_publish

    click_on "Confirm publish"
  end

  def then_the_change_note_and_update_type_should_be_cleared_for_the_next_edition
    visit edit_document_path(@document)

    expect(page.find("textarea[name='document[change_note]']").text).to be_empty
    expect(page).to have_selector("input[name='document[update_type]'][checked='checked'][value='major']")
  end
end
