# frozen_string_literal: true

RSpec.feature "Choose a lead image" do
  scenario "User chooses an existing image as lead image" do
    given_there_is_a_document_with_existing_images
    when_i_visit_the_summary_page
    and_i_visit_the_lead_images_page
    then_i_should_be_able_to_see_a_list_of_existing_images
  end

  def given_there_is_a_document_with_existing_images
    document_type_schema = build(:document_type_schema, lead_image: true)
    document = create(:document, document_type: document_type_schema.id)
    create(:image, document: document, filename: "image-1.jpg")
    create(:image, document: document, filename: "image-2.jpg")
  end

  def when_i_visit_the_summary_page
    visit document_path(Document.last)
  end

  def and_i_visit_the_lead_images_page
    click_on "Change Lead image"
  end

  def then_i_should_be_able_to_see_a_list_of_existing_images
    expect(find("#image-0")["src"]).to include("image-1.jpg")
    expect(page).to have_content("image-1.jpg")
    expect(find("#image-1")["src"]).to include("image-2.jpg")
    expect(page).to have_content("image-2.jpg")
  end
end
