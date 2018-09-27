# frozen_string_literal: true

RSpec.feature "Remove a lead image" do
  scenario "Remove a lead image" do
    given_there_is_a_document_with_a_lead_image
    when_i_visit_the_lead_images_page
    then_i_see_the_lead_image
    when_i_remove_the_lead_image
    then_the_document_has_no_lead_image
  end

  def given_there_is_a_document_with_a_lead_image
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image = create(:image, document: document, filename: "image-1.jpg",
                              alt_text: "image 1 alt text", caption: "image 1 caption",
                              credit: "image 1 credit")
    document.update(lead_image: @image)
  end

  def when_i_visit_the_lead_images_page
    visit document_lead_image_path(Document.last)
  end

  def then_i_see_the_lead_image
    expect(find("#image-#{@image.id} img")["src"]).to include("image-1.jpg")

    within("#image-#{@image.id}") do
      expect(page).to have_content(@image.alt_text)
      expect(page).to have_content(@image.caption)
      expect(page).to have_content(@image.credit)
      expect(page).to have_content(I18n.t("document_lead_image.index.lead_image"))
    end
  end

  def when_i_remove_the_lead_image
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Remove"
  end

  def then_the_document_has_no_lead_image
    expect(@request).to have_been_requested
    expect(page).to have_link("Preview")

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"].keys).to_not include("image")
    }).to have_been_requested

    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))
  end
end
