# frozen_string_literal: true

RSpec.feature "Edit a lead image" do
  scenario "User edits a lead image" do
    given_there_is_a_document
    when_i_visit_the_summary_page
    then_i_see_there_is_no_lead_image
    when_i_visit_the_lead_images_page
    then_i_should_see_no_images_available
    and_i_upload_a_new_image
    and_i_fill_in_the_metadata
    then_i_should_be_able_to_see_the_image
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    create(:document, document_type: document_type_schema.id)
  end

  def when_i_visit_the_summary_page
    visit document_path(Document.last)
  end

  def then_i_see_there_is_no_lead_image
    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))
  end

  def when_i_visit_the_lead_images_page
    click_on "Change Lead image"
  end

  def then_i_should_see_no_images_available
    expect(page).to have_content(I18n.t("document_lead_image.index.no_existing_image"))
  end

  def and_i_upload_a_new_image
    find('form input[type="file"]').set(file_fixture("960x640.jpg"))
    click_on "Upload"
  end

  def and_i_fill_in_the_metadata
    expect(find(:img)["src"]).to include("960x640.jpg")
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "Image caption"
    fill_in "credit", with: "Image credit"
    click_on "Save and choose"
  end

  def then_i_should_be_able_to_see_the_image
    expect(page).to have_content("Image caption")
    expect(page).to have_content("Image credit")
    expect(find("#lead-image")["src"]).to include("960x640.jpg")
    expect(find("#lead-image")["alt"]).to eq("Some alt text")
  end
end
