# frozen_string_literal: true

RSpec.feature "Delete draft" do
  scenario "Delete draft" do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_delete_the_draft
    then_i_see_the_document_is_gone
    and_the_draft_is_discarded
  end

  def given_there_is_a_document
    @document = create(:document)
    @image = create(:image, :in_asset_manager, document: @document)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_delete_the_draft
    @content_request = stub_publishing_api_discard_draft(@document.content_id)
    # TODO: add this to gds-api-adapters test helpers
    @image_request = stub_request(:delete, "https://asset-manager.test.gov.uk/assets/#{@image.asset_manager_id}")

    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_document_is_gone
    expect(page).to have_current_path(documents_path)
    expect(page).to_not have_content @document.title
  end

  def and_the_draft_is_discarded
    expect(@content_request).to have_been_requested
    expect(@image_request).to have_been_requested
  end
end
