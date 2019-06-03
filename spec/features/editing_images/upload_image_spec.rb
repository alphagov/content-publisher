# frozen_string_literal: true

RSpec.feature "Upload an image", js: true do
  scenario "lead image" do
    given_there_is_an_edition
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_new_image
    and_the_preview_creation_succeeded
  end

  scenario "inline image" do
    given_there_is_an_edition
    when_i_insert_an_inline_image
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_snippet_is_inserted
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_insert_an_inline_image
    visit edit_document_path(@edition.document)

    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Image"
    end
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

  def then_i_see_the_uploaded_image
    expect(page).to have_selector(".app-c-image-meta")

    within("#image-#{Image.first.id}") do
      expect(find("img")["src"]).to include("1000x1000.jpg")
      expect(page).to have_link("Insert image markdown")
    end
  end

  def then_i_see_the_new_image
    within("#image-#{Image.first.id}") do
      expect(page).to have_content("A caption")
      expect(page).to have_content("A credit")
      expect(page).to have_content(I18n.t("images.index.meta.inline_code.value", filename: "1000x1000.jpg"))

      expect(find("img")["src"]).to include("1000x1000.jpg")
      expect(find("img")["alt"]).to eq("Some alt text")
    end
  end

  def then_i_see_the_snippet_is_inserted
    expect(page).to_not have_selector(".gem-c-modal-dialogue")
    snippet = I18n.t("images.index.meta.inline_code.value", filename: @image_filename)
    expect(find("#revision_body").value).to match snippet
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested
    expect(@asset_manager_request).to have_been_requested.at_least_once

    visit document_path(@edition.document)

    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_updated"))
  end
end
