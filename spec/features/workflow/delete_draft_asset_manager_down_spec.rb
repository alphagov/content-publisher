# frozen_string_literal: true

RSpec.feature "Delete draft with Asset Manager down" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_asset_manager_is_down
    and_i_delete_the_draft
    then_i_see_the_deletion_failed
    when_asset_manager_is_up_and_i_try_again
    then_i_see_the_edition_is_gone
  end

  def given_there_is_an_edition
    @image_revision = create(:image_revision, :on_asset_manager)
    @edition = create(:edition,
                      lead_image_revision: @image_revision,
                      created_by: current_user)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_asset_manager_is_down
    stub_asset_manager_isnt_available
  end

  def when_asset_manager_is_up_and_i_try_again
    stub_asset_manager_deletes_any_asset
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

  def then_i_see_the_edition_is_gone
    expect(page).to have_current_path(documents_path, ignore_query: true)
    expect(page).to_not have_content @edition.title
  end
end
