# frozen_string_literal: true

RSpec.feature "Remove a lead image" do
  scenario "User removes an existing lead image" do
    given_there_is_a_document_with_a_lead_image
    when_i_visit_the_lead_images_page
    then_i_should_be_able_to_see_the_lead_image
    when_i_remove_the_lead_image
    then_i_should_not_see_a_lead_image_on_the_summary_page
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

  def then_i_should_be_able_to_see_the_lead_image
    expect(find("#image-0")["src"]).to include("image-1.jpg")
    within("td#image-0-metadata") do
      expect(page).to have_content(@image.alt_text)
      expect(page).to have_content(@image.caption)
      expect(page).to have_content(@image.credit)
      expect(page).to have_content("Lead image")
    end
  end

  def when_i_remove_the_lead_image
    within("td#image-0-metadata") do
      click_on "Remove"
    end
  end

  def then_i_should_not_see_a_lead_image_on_the_summary_page
    expect(page).to have_content(I18n.t("documents.show.lead_image.no_lead_image"))
  end
end
