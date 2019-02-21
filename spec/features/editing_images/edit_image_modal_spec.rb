# frozen_string_literal: true

RSpec.feature "Edit image in a modal", js: true do
  scenario do
    given_there_is_an_edition_with_images
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_an_image
    and_i_edit_the_image_crop
    then_the_image_crop_is_updated
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition_with_images
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @edition = create(:edition, document_type_id: document_type.id)

    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             crop_x: 0,
                             crop_y: 167,
                             crop_width: 1000,
                             crop_height: 666,
                             fixture: "1000x1000.jpg")

    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_go_to_edit_the_edition
    visit edit_document_path(@edition.document)
  end

  def and_i_click_to_insert_an_image
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
  end

  def and_i_edit_the_image_crop
    click_on "Edit image"

    # drag towards the top of the page where the page heading is located
    crop_box = find(".cropper-crop-box")
    crop_box.drag_to(find(".govuk-heading-l"))

    bottom_right_handle = find(".cropper-point.point-se")
    bottom_right_handle.drag_to(find(".govuk-heading-l"))

    @publishing_api_request = stub_any_publishing_api_put_content
    @new_asset_requests = stub_asset_manager_receives_an_asset
    @old_asset_requests = stub_asset_manager_deletes_any_asset

    click_on "Crop image"
  end

  def then_the_image_crop_is_updated
    expect(page).to have_selector(".app-c-image-meta")
    image_revision = @edition.reload.image_revisions[0]
    expect(image_revision.crop_y).to eq(0)
    expect(image_revision.crop_x).to eq(1)
    expect(image_revision.crop_width).to eq(960)
    expect(image_revision.crop_height).to eq(640)
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested.at_least_once
    expect(@new_asset_requests).to have_been_requested.at_least_once
    expect(@old_asset_requests).to have_been_requested.at_least_once

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested.at_least_once
  end
end
