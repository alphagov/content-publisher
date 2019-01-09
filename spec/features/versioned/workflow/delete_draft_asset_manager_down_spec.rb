# frozen_string_literal: true

RSpec.feature "Delete draft with Asset Manager down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_asset_manager_is_down
    and_i_delete_the_draft
    then_i_see_the_deletion_failed
    when_asset_manager_is_up_and_i_try_again
    then_i_see_the_document_is_gone
  end

  def given_there_is_a_document
    @image_revision = create(:versioned_image_revision, :on_asset_manager)
    @edition = create(:versioned_edition, lead_image_revision: @image_revision)
  end

  def when_i_visit_the_document_page
    visit versioned_document_path(@edition.document)
  end

  def and_asset_manager_is_down
    stub_request(:any, /#{Plek.new.find("asset-manager")}/)
      .to_return(status: 503)
  end

  def when_asset_manager_is_up_and_i_try_again
    stub_request(:any, /#{Plek.new.find("asset-manager")}/)
      .to_return(status: 200)
    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def and_i_delete_the_draft
    stub_any_publishing_api_discard_draft
    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_deletion_failed
    expect(page).to have_content(I18n.t!("documents.show.flashes.delete_draft_error.title"))
    expect(page).to have_content(@edition.title)
  end

  def then_i_see_the_document_is_gone
    expect(page).to have_current_path(versioned_documents_path)
    expect(page).to_not have_content @edition.title
  end
end
