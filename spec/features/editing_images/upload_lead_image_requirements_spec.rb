# frozen_string_literal: true

RSpec.feature "Upload a lead image with requirements issues" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_images_page
    and_i_upload_an_invalid_image
    then_i_should_see_an_error
  end

  def given_there_is_an_edition
    document_type = build(:document_type, lead_image: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit document_path(@edition.document)
    click_on "Change Lead image"
  end

  def and_i_upload_an_invalid_image
    find('form input[type="file"]').set(file_fixture("text-file.txt"))
    click_on "Upload"
  end

  def then_i_should_see_an_error
    expect(page).to have_content(I18n.t!("requirements.image_upload.unsupported_type.form_message"))
  end
end
