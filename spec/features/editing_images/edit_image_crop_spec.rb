# frozen_string_literal: true

RSpec.feature "Edit image crop", js: true do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_lead_images_page
    and_i_edit_the_image_crop
    then_the_image_crop_is_updated
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)

    create(:image,
           :in_asset_manager,
           document: document,
           crop_x: 0,
           crop_y: 167,
           crop_width: 1000,
           crop_height: 666,
           fixture: "1000x1000.jpg")
  end

  def when_i_visit_the_lead_images_page
    visit document_path(Document.last)
    click_on "Change Lead image"
  end

  def and_i_edit_the_image_crop
    click_on "Edit crop"

    # drag towards the top of the page where the page heading is located
    crop_box = find(".cropper-crop-box")
    crop_box.drag_to(find(".govuk-heading-l"))

    bottom_right_handle = find(".cropper-point.point-se")
    bottom_right_handle.drag_to(find(".govuk-heading-l"))

    @upload_request = asset_manager_receives_an_asset("asset_manager_file_url")
    @delete_request = asset_manager_delete_asset(Image.last.asset_manager_id)
    @publishing_api_request = stub_any_publishing_api_put_content

    click_on "Crop image"
  end

  def then_the_image_crop_is_updated
    expect(@upload_request).to have_been_requested
    expect(@delete_request).to have_been_requested
    expect(Image.last.crop_y).to eq(0)
    expect(Image.last.crop_x).to eq(0)
    expect(Image.last.crop_width).to eq(960)
    expect(Image.last.crop_height).to eq(640)
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested

    click_on "Back"
    expect(page).to have_content(I18n.t("user_facing_states.draft.name"))
    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))

    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.image_updated")
  end
end
