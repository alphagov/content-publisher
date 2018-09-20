# frozen_string_literal: true

RSpec.feature "Edit an existing lead image" do
  scenario "User edits lead image" do
    given_there_is_a_document_with_existing_images
    when_i_visit_the_lead_images_page
    and_i_click_edit_details
    then_i_edit_the_image_metadata
    then_i_am_redirected_to_the_lead_images_page
    and_i_should_be_able_to_see_the_edited_metadata
    and_there_is_a_history_entry
  end

  def given_there_is_a_document_with_existing_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, document: document)
  end

  def when_i_visit_the_lead_images_page
    visit document_path(Document.last)
    click_on "Change Lead image"
  end

  def and_i_click_edit_details
    click_on "Edit details"
  end

  def then_i_edit_the_image_metadata
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "Image caption"
    fill_in "credit", with: "Image credit"
    click_on "Save and choose"
  end

  def then_i_am_redirected_to_the_lead_images_page
    expect(@request).to have_been_requested
    expect(page).to have_current_path(document_lead_image_path(Document.last))
  end

  def and_i_should_be_able_to_see_the_edited_metadata
    expect(page).to have_content("Some alt text")
    expect(page).to have_content("Image caption")
    expect(page).to have_content("Image credit")
  end

  def and_there_is_a_history_entry
    visit document_path(Document.last)

    within find(".app-timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.lead_image_updated")
    end
  end
end
