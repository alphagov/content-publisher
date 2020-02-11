RSpec.describe "Remove a lead image" do
  it "on the index page" do
    given_there_is_an_edition_with_a_lead_image
    when_i_visit_the_images_page
    and_i_remove_the_lead_image
    then_the_edition_has_no_lead_image
    and_i_see_the_timeline_entry
  end

  it "on the metadata page" do
    given_there_is_an_edition_with_a_lead_image
    when_i_visit_the_images_page
    and_i_edit_the_image_metadata
    and_i_untick_the_image_is_the_lead_image
    then_the_edition_has_no_lead_image
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition_with_a_lead_image
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             alt_text: "image")
    @edition = create(:edition,
                      document_type: document_type,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def and_i_remove_the_lead_image
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_updates_any_asset
    click_on "Remove lead image"
  end

  def and_i_edit_the_image_metadata
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_updates_any_asset
    visit edit_image_path(@edition.document, @image_revision.image_id)
  end

  def and_i_untick_the_image_is_the_lead_image
    expect(find_field("lead_image").checked?).to eq true
    uncheck(I18n.t!("images.edit.form_labels.lead_image"))
    click_on "Save"
  end

  def then_the_edition_has_no_lead_image
    expect(page).to have_content(I18n.t!("images.index.flashes.lead_image.removed", file: @image_revision.filename))
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_removed"))
  end
end
