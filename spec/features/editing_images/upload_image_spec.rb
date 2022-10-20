RSpec.feature "Upload an image", js: true do
  scenario "lead image" do
    given_there_is_an_edition
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_new_image
    and_i_see_the_timeline_entry
  end

  scenario "inline image" do
    given_there_is_an_edition
    when_i_insert_an_inline_image
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_snippet_is_inserted
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition
    document_type = build(:document_type, :with_body, :with_lead_image)
    @edition = create(:edition, document_type:)
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

  def and_i_upload_a_new_image
    @image_filename = "1000x1000.jpg"
    find('form input[type="file"]').set(Rails.root.join(file_fixture(@image_filename)))
    click_on "Upload"
  end

  def and_i_crop_the_image
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_receives_an_asset(filename: @image_filename)
    click_on "Save and continue"
  end

  def and_i_fill_in_the_metadata
    stub_asset_manager_updates_any_asset
    fill_in "image_revision[alt_text]", with: "Some alt text"
    fill_in "image_revision[caption]", with: "A caption"
    fill_in "image_revision[credit]", with: "A credit"
    click_on "Save"
  end

  def then_i_see_the_uploaded_image
    expect(page).to have_selector(".app-c-image-with-metadata")

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
    expect(page).not_to have_selector(".gem-c-modal-dialogue")
    snippet = I18n.t("images.index.meta.inline_code.value", filename: @image_filename)
    expect(find("#body-field").value).to match snippet
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_updated"))
  end
end
