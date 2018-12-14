# frozen_string_literal: true

RSpec.feature "Delete an image" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    document = create(:document, document_type_id: document_type.id)
    @image = create(:image, :in_preview, document: document)
  end

  def when_i_visit_the_images_page
    visit images_path(Document.last)
  end

  def and_i_delete_the_non_lead_image
    @image_request = asset_manager_delete_asset(@image.asset_manager_id)
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Delete image"
  end

  def then_i_see_the_image_is_gone
    expect(all("#image-#{@image.id}").count).to be_zero
    expect(page).to have_content(I18n.t!("document_images.index.flashes.deleted", file: @image.filename))

    expect(@image_request).to have_been_requested
    expect(ActiveStorage::Blob.service.exist?(@image.blob.key)).to be_falsey

    click_on "Back"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_removed"))
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested
  end
end
