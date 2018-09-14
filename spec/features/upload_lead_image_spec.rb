# frozen_string_literal: true

RSpec.feature "Upload a lead image" do
  scenario "User uploads a lead image" do
    given_there_is_a_document
    when_i_visit_the_summary_page
    then_i_see_there_is_no_lead_image
    when_i_visit_the_lead_images_page
    then_i_should_see_no_images_available
    when_i_upload_a_new_image
    and_i_fill_in_the_metadata
    then_i_should_be_able_to_see_the_lead_image_on_the_summary_page
  end

  scenario "User uploads a lead image and asset manager fails to upload it" do
    given_there_is_a_document
    when_i_upload_a_new_image_and_asset_manager_is_unable_to_upload_it
    then_i_should_see_an_error
    and_i_should_not_be_able_to_see_the_image_on_the_lead_images_page
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

  def when_i_upload_a_new_image
    asset_manager_receives_an_asset("a-url")
    find('form input[type="file"]').set(file_fixture("960x640.jpg"))
    click_on "Upload"
  end

  def and_i_fill_in_the_metadata
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    expect(find(".app-c-image-meta__image")["src"]).to include("960x640.jpg")
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "Image caption"
    fill_in "credit", with: "Image credit"
    click_on "Save and choose"
  end

  def then_i_should_be_able_to_see_the_lead_image_on_the_summary_page
    expect(@request).to have_been_requested
    expect(page).to have_content("Image caption")
    expect(page).to have_content("Image credit")
    expect(find("#lead-image .app-c-image-meta__image")["src"]).to include("960x640.jpg")
    expect(find("#lead-image .app-c-image-meta__image")["alt"]).to eq("Some alt text")
  end

  def when_i_upload_a_new_image_and_asset_manager_is_unable_to_upload_it
    visit document_lead_image_path(Document.last)
    asset_manager_upload_failure
    find('form input[type="file"]').set(file_fixture("960x640.jpg"))
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.asset_manager_error.title"))
  end

  def and_i_should_not_be_able_to_see_the_image_on_the_lead_images_page
    expect(page).not_to have_select("#lead-image")
  end
end
