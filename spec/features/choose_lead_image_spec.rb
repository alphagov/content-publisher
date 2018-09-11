# frozen_string_literal: true

RSpec.feature "Choose a lead image" do
  scenario "User chooses an existing image as lead image" do
    given_there_is_a_document_with_existing_images
    when_i_visit_the_summary_page
    and_i_visit_the_lead_images_page
    then_i_should_be_able_to_see_a_list_of_existing_images
    when_i_select_an_image_to_be_the_lead_image
    then_i_should_see_the_new_lead_image_on_the_summary_page
  end

  def given_there_is_a_document_with_existing_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    @image1 = create(:image, document: document, filename: "image-1.jpg",
                              alt_text: "image 1 alt text", caption: "image 1 caption",
                              credit: "image 1 credit")
    create(:image, document: document, filename: "image-2.jpg")
    document.update(lead_image: @image1)
  end

  def when_i_visit_the_summary_page
    visit document_path(Document.last)
  end

  def and_i_visit_the_lead_images_page
    click_on "Change Lead image"
  end

  def then_i_should_be_able_to_see_a_list_of_existing_images
    expect(find("#image-0")["src"]).to include("image-1.jpg")
    within("td#image-0-metadata") do
      expect(page).to have_content(@image1.alt_text)
      expect(page).to have_content(@image1.caption)
      expect(page).to have_content(@image1.credit)
      expect(page).to have_content("Lead image")
    end

    expect(find("#image-1")["src"]).to include("image-2.jpg")
  end

  def when_i_select_an_image_to_be_the_lead_image
    within("td#image-1-choose-action") do
      click_on "Choose image"
    end
  end

  def then_i_should_see_the_new_lead_image_on_the_summary_page
    expect(find("#lead-image")["src"]).to include("image-2.jpg")
  end
end
