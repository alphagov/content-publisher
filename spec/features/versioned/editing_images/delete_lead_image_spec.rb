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
    document_type = build(:document_type, lead_image: true)
    @image_revision = create(:versioned_image_revision, :on_asset_manager)
    @edition = create(:versioned_edition,
                      document_type_id: document_type.id,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_images_page
    visit versioned_images_path(@edition.document)
  end

  def when_i_delete_the_lead_image
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Delete lead image"
  end

  def then_i_see_the_document_has_no_lead_image
    expect(page).to have_content(I18n.t!("documents.show.flashes.lead_image.deleted", file: @image_revision.filename))
    expect(page).to have_content(I18n.t!("documents.show.lead_image.no_lead_image"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_removed"))
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested
  end
end
