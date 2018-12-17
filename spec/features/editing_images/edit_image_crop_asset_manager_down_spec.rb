# frozen_string_literal: true

RSpec.feature "Edit image crop when Asset Manager is down", js: true do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_asset_manager_is_down
    and_i_crop_the_image
    then_i_see_the_image_is_unchanged
    and_the_api_operation_failed
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    document = create(:document, document_type_id: document_type.id)
    create(:image, :in_preview, document: document, crop_y: 167, fixture: "1000x1000.jpg")
  end

  def when_i_visit_the_images_page
    visit images_path(Document.last)
  end

  def and_asset_manager_is_down
    asset_manager_upload_failure
  end

  def and_i_crop_the_image
    click_on "Edit crop"

    # drag towards the top of the page where the page heading is located
    crop_box = find(".cropper-crop-box")
    crop_box.drag_to(find(".govuk-heading-l"))

    click_on "Crop image"
  end

  def then_i_see_the_image_is_unchanged
    expect(Image.last.crop_y).to_not eq(0)
  end

  def and_the_api_operation_failed
    expect(page).to have_content(I18n.t!("images.index.flashes.api_error.title"))
  end
end
