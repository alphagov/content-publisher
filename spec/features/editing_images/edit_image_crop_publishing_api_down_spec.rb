# frozen_string_literal: true

RSpec.feature "Edit image crop when Publishing API is down", js: true do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_lead_images_page
    and_the_publishing_api_is_down
    and_i_crop_the_image
    then_i_see_the_image_is_updated
    and_the_preview_creation_failed
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, :in_asset_manager, document: document, crop_y: 167, fixture: "1000x1000.jpg")
  end

  def when_i_visit_the_lead_images_page
    visit document_path(Document.last)
    click_on "Change Lead image"
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_crop_the_image
    click_on "Edit crop"

    # drag towards the top of the page where the page heading is located
    crop_box = find(".cropper-crop-box")
    crop_box.drag_to(find(".govuk-heading-l"))

    @upload_request = asset_manager_receives_an_asset("asset_manager_file_url")
    @delete_request = asset_manager_delete_asset(Image.last.asset_manager_id)

    click_on "Crop image"
  end

  def then_i_see_the_image_is_updated
    expect(@upload_request).to have_been_requested
    expect(@delete_request).to have_been_requested
    expect(Image.last.crop_y).to eq(0)
  end

  def and_the_preview_creation_failed
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.api_error.title"))
  end
end
