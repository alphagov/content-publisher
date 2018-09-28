# frozen_string_literal: true

RSpec.feature "Upload a lead image when Publishing API is down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_lead_images_page
    and_the_publishing_api_is_down
    when_i_upload_an_image
    then_i_see_the_image_is_the_lead_image
    and_i_see_the_preview_creation_failed
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    create(:document, document_type: document_type_schema.id)
  end

  def when_i_visit_the_lead_images_page
    visit document_lead_image_path(Document.last)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_upload_an_image
    @asset_id = SecureRandom.uuid
    asset_url = "https://asset-manager.test.gov.uk/media/#{@asset_id}/960x640.jpg"
    asset_manager_receives_an_asset(asset_url)

    find('form input[type="file"]').set(file_fixture("960x640.jpg"))
    click_on "Upload"

    asset_manager_delete_asset(@asset_id)
    click_on "Crop image"

    fill_in "alt_text", with: "Some alt text"
    click_on "Save and choose"
  end

  def then_i_see_the_image_is_the_lead_image
    within("#image-#{Image.last.id}") do
      expect(page).to have_content(I18n.t("document_lead_image.index.lead_image"))
    end
  end

  def and_i_see_the_preview_creation_failed
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.api_error.title"))
  end
end
