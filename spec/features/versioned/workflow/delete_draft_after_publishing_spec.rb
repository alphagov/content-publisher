# frozen_string_literal: true

RSpec.feature "Delete draft after publishing" do
  scenario do
    given_there_is_a_edition
    when_i_visit_the_document_page
    and_i_publish_the_document
    and_i_create_a_new_draft
    and_i_delete_the_draft
    then_i_see_the_draft_is_gone
  end

  def given_there_is_a_edition
    @edition = create(:versioned_edition, :publishable)
  end

  def when_i_visit_the_document_page
    visit versioned_document_path(@edition.document)
  end

  def when_i_submit_for_2i_review
    click_on "Submit for 2i review"
  end

  def and_i_publish_the_document
    stub_any_publishing_api_publish
    click_on "Publish"
    choose I18n.t!("publish.confirmation.should_be_reviewed")
    click_on "Confirm publish"
    click_on "Back"
  end

  def and_i_create_a_new_draft
    stub_any_publishing_api_put_content
    @new_title = "New draft"
    click_on "Create new edition"
    click_on "Save"
  end

  def and_i_delete_the_draft
    stub_any_publishing_api_discard_draft
    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_draft_is_gone
    expect(page).to have_current_path(versioned_documents_path)
    expect(page).to_not have_content @new_title
    expect(page).to have_content @edition.title
  end
end
