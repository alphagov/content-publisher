# frozen_string_literal: true

RSpec.feature "Delete draft" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_delete_the_draft
    then_i_see_the_document_is_gone
    and_the_draft_is_discarded
  end

  def given_there_is_a_document
    @image_revision = create(:versioned_image_revision, :on_asset_manager)
    @edition = create(:versioned_edition, lead_image_revision: @image_revision)
  end

  def when_i_visit_the_document_page
    visit versioned_document_path(@edition.document)
  end

  def and_i_delete_the_draft
    @content_request = stub_publishing_api_discard_draft(@edition.content_id)
    @image_request = stub_request(:delete, /#{Plek.new.find("asset-manager")}/)

    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_document_is_gone
    expect(page).to have_current_path(versioned_documents_path)
    expect(page).to_not have_content @edition.title
  end

  def and_the_draft_is_discarded
    expect(@content_request).to have_been_requested
    expect(@image_request).to have_been_requested.at_least_once
  end
end
