# frozen_string_literal: true

RSpec.feature "Edit an existing lead image's crop dimensions", js: true do
  scenario "User edits lead image crop" do
    given_there_is_a_document_with_existing_images
    when_i_visit_the_lead_images_page
    and_i_click_edit_crop
    and_i_crop_the_image
    then_i_am_redirected_to_the_lead_images_page
    and_the_image_has_been_cropped
  end

  def given_there_is_a_document_with_existing_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, :in_asset_manager, document: document)
  end

  def when_i_visit_the_lead_images_page
    visit document_path(Document.last)
    click_on "Change Lead image"
  end

  def and_i_click_edit_crop
    click_on "Edit crop"
  end

  def and_i_crop_the_image
    expect(page).to have_content(I18n.t("document_lead_image.crop.description"))
    crop_box = find(".cropper-crop-box")
    # drag towards the top of the page where the page heading is located
    target = find(".govuk-heading-l")
    crop_box.drag_to(target)
    @new_asset_id = SecureRandom.uuid
    asset_url = "https://asset-manager.test.gov.uk/media/#{@new_asset_id}/1000x1000.jpg"
    @upload_request = asset_manager_receives_an_asset(asset_url)
    @delete_request = asset_manager_delete_asset(Image.last.asset_manager_id)
    click_on "Crop image"
  end

  def then_i_am_redirected_to_the_lead_images_page
    expect(page).to have_current_path(document_lead_image_path(Document.last))
  end

  def and_the_image_has_been_cropped
    expect(@upload_request).to have_been_requested
    expect(@delete_request).to have_been_requested
    expect(Image.last.crop_y).to eq(0)
  end
end
