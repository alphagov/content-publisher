# frozen_string_literal: true

RSpec.feature "Upload a lead image when Publishing API is down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_summary_page
    then_i_see_there_is_no_lead_image
    when_i_visit_the_lead_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_the_publishing_api_is_down
    and_i_fill_in_the_metadata
    then_i_see_the_new_lead_image
    and_the_preview_creation_failed
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

  def and_i_upload_a_new_image
    @asset_id = SecureRandom.uuid
    @asset_url = "https://asset-manager.test.gov.uk/media/#{@asset_id}/1000x1000.jpg"
    asset_manager_receives_an_asset(@asset_url)
    find('form input[type="file"]').set(Rails.root.join(file_fixture("1000x1000.jpg")))
    click_on "Upload"
  end

  def and_i_crop_the_image
    asset_manager_delete_asset(@asset_id)
    stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Crop image"
    WebMock.reset!
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_fill_in_the_metadata
    click_on "Save and choose"
  end

  def then_i_see_the_new_lead_image
    within("#image-#{Image.last.id}") do
      expect(page).to have_content(I18n.t("document_lead_image.index.lead_image"))
    end
  end

  def and_the_preview_creation_failed
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.api_error.title"))
  end
end
