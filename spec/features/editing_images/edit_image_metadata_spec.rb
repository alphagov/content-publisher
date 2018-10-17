# frozen_string_literal: true

RSpec.feature "Edit image metadata" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_metadata
    then_i_see_the_image_is_updated
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, document: document)
  end

  def when_i_visit_the_images_page
    visit document_images_path(Document.last)
  end

  def and_i_edit_the_image_metadata
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Edit details"
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "A caption"
    fill_in "credit", with: "A credit"
    click_on "Save details"
  end

  def then_i_see_the_image_is_updated
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("document_images.index.flashes.details_edited", filename: Image.last.filename))
    expect(page).to have_content("Some alt text")
    expect(page).to have_content("A caption")
    expect(page).to have_content("A credit")
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested

    click_on "Back"
    expect(page).to have_content(I18n.t("user_facing_states.draft.name"))
    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))
    expect(page).to have_content I18n.t!("documents.history.entry_types.image_updated")
  end
end
