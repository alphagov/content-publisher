# frozen_string_literal: true

RSpec.feature "Edit a lead image" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_summary_page
    and_i_visit_the_lead_images_page
    and_i_upload_an_invalid_image
    then_i_should_see_an_error
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

  def and_i_upload_an_invalid_image
    find('form input[type="file"]').set(file_fixture("text-file.txt"))
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t("validations.images.invalid_format"))
  end
end
