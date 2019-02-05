# frozen_string_literal: true

RSpec.feature "Edit image metadata" do
  scenario do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_metadata
    then_i_see_the_image_is_updated
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def and_i_edit_the_image_metadata
    @publishing_api_request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Edit details"
    fill_in "image_revision[alt_text]", with: "Some alt text"
    fill_in "image_revision[caption]", with: "A caption"
    fill_in "image_revision[credit]", with: "A credit"
    click_on "Save"
  end

  def then_i_see_the_image_is_updated
    expect(page).to have_content(I18n.t!("images.index.flashes.details_edited", file: @image_revision.filename))
    expect(page).to have_content("Some alt text")
    expect(page).to have_content("A caption")
    expect(page).to have_content("A credit")
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
    expect(page).to have_content I18n.t!("documents.history.entry_types.image_updated")
  end
end
