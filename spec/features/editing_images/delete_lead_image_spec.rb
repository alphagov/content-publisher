# frozen_string_literal: true

RSpec.feature "Delete an image" do
  scenario do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    when_i_delete_the_lead_image
    then_i_see_the_document_has_no_lead_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition_with_images
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def when_i_delete_the_lead_image
    @put_content_request = stub_publishing_api_put_content(@edition.content_id, {})
    @delete_asset_request = stub_asset_manager_deletes_any_asset
    click_on "Delete lead image"
  end

  def then_i_see_the_document_has_no_lead_image
    expect(all("#image-#{@image_revision.image_id}").count).to be_zero
    expect(page).to have_content(I18n.t!("images.index.flashes.lead_image.deleted", file: @image_revision.filename))

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_removed"))
  end

  def and_the_preview_creation_succeeded
    expect(@put_content_request).to have_been_requested
    expect(@delete_asset_request).to have_been_requested.at_least_once
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested
  end
end
