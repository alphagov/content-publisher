# frozen_string_literal: true

RSpec.feature "Upload a lead image with requirements issues" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_enter_bad_metadata
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    create(:document, document_type: document_type_schema.id)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
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
  end

  def and_i_enter_bad_metadata
    click_on "Save and choose"
  end

  def then_i_see_an_error_to_fix_the_issues
    expect(page).to have_content(I18n.t!("requirements.alt_text.blank.form_message"))
  end
end
