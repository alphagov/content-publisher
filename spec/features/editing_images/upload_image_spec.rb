# frozen_string_literal: true

RSpec.feature "Upload an image" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_new_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition
    document_type = build(:document_type, images: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def and_i_upload_a_new_image
    @image_filename = "1000x1000.jpg"

    find('form input[type="file"]').set(Rails.root.join(file_fixture(@image_filename)))
    click_on "Upload"
  end

  def and_i_crop_the_image
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Crop image"
    reset_executed_requests!
  end

  def and_i_fill_in_the_metadata
    @publishing_api_request = stub_publishing_api_put_content(@edition.content_id, {})
    @asset_manager_request = stub_asset_manager_receives_an_asset(filename: @image_filename)

    fill_in "image_revision[alt_text]", with: "Some alt text"
    fill_in "image_revision[caption]", with: "A caption"
    fill_in "image_revision[credit]", with: "A credit"
    click_on "Save"
  end

  def then_i_see_the_new_image
    within("#image-#{Image.first.id}") do
      expect(page).to have_content("A caption")
      expect(page).to have_content("A credit")
      expect(find("img")["src"]).to include("1000x1000.jpg")
      expect(find("img")["alt"]).to eq("Some alt text")
    end

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_updated"))
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested
    expect(@asset_manager_request).to have_been_requested.at_least_once
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
  end
end
