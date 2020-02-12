RSpec.feature "Delete an image" do
  scenario do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    when_i_delete_the_lead_image
    then_i_see_the_document_has_no_lead_image
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      document_type: document_type,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_delete_the_lead_image
    stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Delete lead image"
  end

  def then_i_see_the_document_has_no_lead_image
    expect(all("#image-#{@image_revision.image_id}").count).to be_zero
    expect(page).to have_content(I18n.t!("images.index.flashes.lead_image.deleted", file: @image_revision.filename))

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_deleted"))
  end
end
