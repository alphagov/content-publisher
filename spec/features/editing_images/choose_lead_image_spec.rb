# frozen_string_literal: true

RSpec.feature "Choose a lead image" do
  scenario "on the index page" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_choose_one_of_the_images
    then_the_edition_has_a_lead_image
    and_the_preview_creation_succeeded
  end

  scenario "on the metadata page" do
    given_there_is_an_edition_with_images
    when_i_visit_the_images_page
    and_i_edit_the_image_metadata
    and_i_tick_the_image_is_the_lead_image
    then_the_edition_has_a_lead_image
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
  end

  def and_i_tick_the_image_is_the_lead_image
    expect(find_field("lead_image").checked?).to eq false
    check(I18n.t!("images.edit.form_labels.lead_image"))
    click_on "Save"
  end

  def and_i_choose_one_of_the_images
    @publishing_api_request = stub_publishing_api_put_content(@edition.content_id, {})

    within("#image-#{@image_revision.image_id}") do
      click_on "Select as lead image"
    end
  end

  def then_the_edition_has_a_lead_image
    expect(find("#lead-image img")["src"]).to include(@image_revision.filename)
    expect(page).to have_content(I18n.t!("documents.show.flashes.lead_image.selected", file: @image_revision.filename))
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_selected"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"]["image"]["url"])
        .to eq @image_revision.asset_url("300")
      expect(JSON.parse(req.body)["details"]["image"]["high_resolution_url"])
        .to eq @image_revision.asset_url("high_resolution")
    }).to have_been_requested
  end
end
