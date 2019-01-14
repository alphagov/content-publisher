# frozen_string_literal: true

RSpec.feature "Choose a lead image" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_summary_page
    and_i_visit_the_lead_images_page
    and_i_choose_one_of_the_images
    then_the_document_has_a_lead_image
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      image_revisions: [@image_revision])
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_visit_the_lead_images_page
    click_on "Change Lead image"
  end

  def and_i_choose_one_of_the_images
    @request = stub_publishing_api_put_content(@edition.content_id, {})

    within("#image-#{@image_revision.image_id}") do
      click_on "Select as lead image"
    end
  end

  def then_the_document_has_a_lead_image
    expect(find("#lead-image img")["src"]).to include(@image_revision.filename)
  end

  def and_the_preview_creation_succeeded
    expect(page).to have_content(I18n.t!("documents.show.flashes.lead_image.chosen", file: @image_revision.filename))
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"]["image"]["url"]).to eq @image_revision.asset_url("300")
    }).to have_been_requested
  end
end
