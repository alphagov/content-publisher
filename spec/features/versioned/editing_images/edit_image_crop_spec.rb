# frozen_string_literal: true

RSpec.feature "Edit image crop", js: true do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_crop
    then_the_image_crop_is_updated
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    @image_revision = create(:versioned_image_revision,
                             :on_asset_manager,
                             crop_x: 0,
                             crop_y: 167,
                             crop_width: 1000,
                             crop_height: 666,
                             fixture: "1000x1000.jpg")
    @edition = create(:versioned_edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit versioned_images_path(@edition.document)
  end

  def and_i_edit_the_image_crop
    click_on "Edit crop"

    # drag towards the top of the page where the page heading is located
    crop_box = find(".cropper-crop-box")
    crop_box.drag_to(find(".govuk-heading-l"))

    bottom_right_handle = find(".cropper-point.point-se")
    bottom_right_handle.drag_to(find(".govuk-heading-l"))

    @publishing_api_request = stub_any_publishing_api_put_content

    click_on "Crop image"
  end

  def then_the_image_crop_is_updated
    image_revision = @edition.reload.image_revisions[0]

    expect(image_revision.crop_y).to eq(0)
    expect(image_revision.crop_x).to eq(0)
    expect(image_revision.crop_width).to eq(960)
    expect(image_revision.crop_height).to eq(640)
    expect(page).to have_content(I18n.t!("images.index.flashes.cropped", file: image_revision.filename))
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested

    visit versioned_document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))

    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.image_updated")
  end
end
