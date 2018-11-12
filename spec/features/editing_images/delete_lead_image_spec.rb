# frozen_string_literal: true

RSpec.feature "Delete an image" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    when_i_delete_the_lead_image
    then_i_see_the_document_has_no_lead_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image = create(:image, :in_asset_manager, document: document)
    document.update(lead_image: @image)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def when_i_delete_the_lead_image
    @image_request = asset_manager_delete_asset(@image.asset_manager_id)
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Delete lead image"
  end

  def then_i_see_the_document_has_no_lead_image
    expect(page).to have_content(I18n.t!("documents.show.flashes.lead_image.deleted", file: @image.filename))
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_removed"))
    expect(@image_request).to have_been_requested
    expect(ActiveStorage::Blob.service.exist?(@image.blob.key)).to be_falsey
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested
  end
end
