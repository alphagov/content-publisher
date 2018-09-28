# frozen_string_literal: true

RSpec.feature "Upload a lead image" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_summary_page
    and_i_visit_the_lead_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_new_lead_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, lead_image: true)
    create(:document, document_type: document_type_schema.id)
  end

  def when_i_visit_the_summary_page
    visit document_path(Document.last)
  end

  def and_i_visit_the_lead_images_page
    click_on "Change Lead image"
  end

  def and_i_upload_a_new_image
    @asset_id = SecureRandom.uuid
    @asset_url = "https://asset-manager.test.gov.uk/media/#{@asset_id}/1000x1000.jpg"
    asset_manager_receives_an_asset(@asset_url)
    find('form input[type="file"]').set(Rails.root.join(file_fixture("1000x1000.jpg")))
    click_on "Upload"
  end

  def and_i_crop_the_image
    asset_manager_delete_asset(@asset_id)
    stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Crop image"
    WebMock.reset!
  end

  def and_i_fill_in_the_metadata
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "A caption"
    fill_in "credit", with: "A credit"
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Save and choose"
  end

  def then_i_see_the_new_lead_image
    expect(page).to have_content("A caption")
    expect(page).to have_content("A credit")
    expect(find("#lead-image img")["src"]).to include("1000x1000.jpg")
    expect(find("#lead-image img")["alt"]).to eq("Some alt text")
    expect(page).to have_content(I18n.t("documents.history.entry_types.lead_image_updated"))
    expect(page).to have_content(I18n.t("documents.history.entry_types.image_updated"))
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"]["image"]["url"]).to eq @asset_url
      expect(JSON.parse(req.body)["details"]["image"]["alt_text"]).to eq "Some alt text"
      expect(JSON.parse(req.body)["details"]["image"]["caption"]).to eq "A caption"
    }).to have_been_requested
  end
end
