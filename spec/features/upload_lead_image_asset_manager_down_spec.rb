# frozen_string_literal: true

RSpec.feature "Upload a lead image when Asset Manager is down" do
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
