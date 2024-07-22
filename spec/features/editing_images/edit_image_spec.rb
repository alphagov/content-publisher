RSpec.feature "Edit image", :js do
  scenario "lead image" do
    given_there_is_an_edition_with_a_lead_image
    when_i_visit_the_images_page
    and_i_edit_the_image_crop
    then_the_image_crop_is_updated
    when_i_edit_the_image_metadata
    then_i_see_the_image_is_updated
    and_i_see_the_timeline_entry
  end

  scenario "non-lead image" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_crop
    then_the_image_crop_is_updated
    when_i_edit_the_image_metadata
    then_i_see_the_image_is_updated
    and_i_see_the_timeline_entry
  end

  scenario "inline image" do
    given_there_is_an_edition_with_images
    when_i_insert_an_inline_image
    and_i_edit_the_image_crop
    then_the_image_crop_is_updated
    when_i_edit_the_image_metadata
    then_i_see_the_image_is_updated
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition_with_a_lead_image
    document_type = build(:document_type, :with_lead_image)
    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             crop_x: 0,
                             crop_y: 167,
                             crop_width: 1000,
                             crop_height: 666,
                             fixture: "1000x1000.jpg")
    @edition = create(:edition,
                      document_type:,
                      lead_image_revision: @image_revision)
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, :with_body)

    image_revision = create(:image_revision,
                            :on_asset_manager,
                            crop_x: 0,
                            crop_y: 167,
                            crop_width: 1000,
                            crop_height: 666,
                            fixture: "1000x1000.jpg")
    @edition = create(:edition,
                      document_type:,
                      image_revisions: [image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_insert_an_inline_image
    visit content_path(@edition.document)

    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
  end

  def and_i_edit_the_image_crop
    click_on "Crop image"

    # drag towards the top of the page where the page header is located
    crop_box = find(".cropper-crop-box")
    crop_box.drag_to(find(".govuk-header"))

    bottom_right_handle = find(".cropper-point.point-se")
    bottom_right_handle.drag_to(find(".govuk-header"))

    stub_any_publishing_api_put_content
    stub_asset_manager_receives_an_asset
    stub_asset_manager_updates_any_asset

    click_on "Save"
  end

  def when_i_edit_the_image_metadata
    click_on "Edit details"

    fill_in "image_revision[alt_text]", with: "Some alt text"
    fill_in "image_revision[caption]", with: "A caption"
    fill_in "image_revision[credit]", with: "A credit"
    click_on "Save"
  end

  def then_i_see_the_image_is_updated
    expect(page).to have_content("Some alt text")
    expect(page).to have_content("A caption")
    expect(page).to have_content("A credit")
  end

  def then_the_image_crop_is_updated
    expect(page).to have_selector(".app-c-image-with-metadata")
    image_revision = @edition.reload.image_revisions[0]
    expect(image_revision.crop_y).to be <= 1
    expect(image_revision.crop_x).to be <= 1
    expect(image_revision.crop_width).to eq(960)
    expect(image_revision.crop_height).to eq(640)
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.image_updated")
  end
end
