# frozen_string_literal: true

RSpec.feature "Upload an inline image" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    then_it_has_a_normalised_filename
  end

  def given_there_is_a_document
    document_type = build(:document_type, lead_image: true)
    @document = create(:document, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit images_path(@document)
  end

  def and_i_upload_a_new_image
    asset_manager_receives_an_asset("asset_manager_file_url")
    find('form input[type="file"]').set(Rails.root.join(file_fixture("Bad $ name.png")))
    click_on "Upload"
  end

  def then_it_has_a_normalised_filename
    expect(Image.last.filename).to eq "bad-name.jpg"
  end
end
