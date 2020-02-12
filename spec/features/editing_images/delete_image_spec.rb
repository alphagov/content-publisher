RSpec.feature "Delete an image" do
  scenario "lead image" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    and_i_see_the_timeline_entry
  end

  scenario "inline image", js: true do
    given_there_is_an_edition_with_images
    when_i_insert_an_inline_image
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, :with_body, images: true)
    @image_revision = create(:image_revision, :on_asset_manager)

    @edition = create(:edition,
                      document_type: document_type,
                      image_revisions: [@image_revision])
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

  def and_i_delete_the_non_lead_image
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Delete image"
  end

  def then_i_see_the_image_is_gone
    expect(page).to have_content(I18n.t!("images.index.flashes.deleted", file: @image_revision.filename))
    expect(page).not_to have_selector("#image-#{@image_revision.image_id}")
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_deleted"))
  end
end
