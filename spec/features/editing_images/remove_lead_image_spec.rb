# frozen_string_literal: true

RSpec.feature "Remove a lead image" do
  scenario "on the index page" do
    given_there_is_an_edition_with_a_lead_image
    when_i_visit_the_images_page
    and_i_remove_the_lead_image
    then_the_edition_has_no_lead_image
    and_the_preview_creation_succeeded
  end

  scenario "on the metadata page" do
    given_there_is_an_edition_with_a_lead_image
    when_i_visit_the_images_page
    and_i_edit_the_image_metadata
    and_i_untick_the_image_is_the_lead_image
    then_the_edition_has_no_lead_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_an_edition_with_a_lead_image
    document_type = build(:document_type, images: true)
    @image_revision = create(:image_revision,
                             :on_asset_manager,
                             alt_text: "image")
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      lead_image_revision: @image_revision)
  end

  def when_i_visit_the_images_page
    visit images_path(@edition.document)
  end

  def and_i_remove_the_lead_image
    @publishing_api_request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Remove lead image"
  end

  def and_i_edit_the_image_metadata
    @publishing_api_request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Edit details"
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

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_removed"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested
  end
end
