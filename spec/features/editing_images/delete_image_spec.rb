# frozen_string_literal: true

RSpec.feature "Delete an image" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_lead_images_page
    and_i_delete_the_non_lead_image
    then_i_see_the_image_is_gone
    when_i_delete_the_lead_image
    and_i_visit_the_document_page
    then_i_see_the_document_has_no_lead_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)

    @image = create(:image, :in_asset_manager, document: document)
    @lead_image = create(:image, :in_asset_manager, document: document)

    document.update(lead_image: @lead_image)
  end

  def when_i_visit_the_lead_images_page
    visit document_lead_image_path(Document.last)
  end

  def and_i_delete_the_non_lead_image
    @image_request = asset_manager_delete_asset(@image.asset_manager_id)

    within("#image-#{@image.id}") do
      click_on "Delete image"
    end
  end

  def then_i_see_the_image_is_gone
    expect(all("#image-#{@image.id}").count).to be_zero
    expect(page).to have_content(I18n.t("document_lead_image.index.flashes.image_deleted"))
    expect(@image_request).to have_been_requested
    expect(ActiveStorage::Blob.service.exist?(@image.blob.key)).to be_falsey
  end

  def when_i_delete_the_lead_image
    @lead_image_request = asset_manager_delete_asset(@lead_image.asset_manager_id)
    @request = stub_publishing_api_put_content(Document.last.content_id, {})

    within("#image-#{@lead_image.id}") do
      click_on "Delete image"
    end
  end

  def and_i_visit_the_document_page
    click_on "Back"
  end

  def then_i_see_the_document_has_no_lead_image
    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))
    expect(page).to have_content(I18n.t("documents.history.entry_types.lead_image_removed"))
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested
  end
end
