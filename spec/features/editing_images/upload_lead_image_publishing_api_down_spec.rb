# frozen_string_literal: true

RSpec.feature "Upload a lead image when Publishing API is down" do
  scenario "User uploads a lead image and the draft document is not sent to Publishing API" do
    given_there_is_a_document
    when_i_upload_a_new_image_and_publishing_api_is_down
    then_i_should_see_an_error
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    create(:document, document_type: document_type_schema.id)
  end

  def when_i_upload_a_new_image_and_publishing_api_is_down
    publishing_api_isnt_available
    @asset_id = SecureRandom.uuid
    asset_url = "https://asset-manager.test.gov.uk/media/#{@asset_id}/960x640.jpg"
    asset_manager_receives_an_asset(asset_url)
    visit document_lead_image_path(Document.last)
    find('form input[type="file"]').set(file_fixture("960x640.jpg"))
    click_on "Upload"
    fill_in "alt_text", with: "Some alt text"
    click_on "Save and choose"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.publishing_api_error.title"))
  end
end
