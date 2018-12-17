# frozen_string_literal: true

RSpec.feature "Delete draft after publishing" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_publish_the_document
    and_i_create_a_new_draft
    then_i_cannot_delete_the_draft
    when_i_submit_for_2i_review
    then_i_cannot_delete_the_draft
  end

  def given_there_is_a_document
    @document = create(:document, :publishable)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
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
    click_on "Create new edition"
    click_on "Save"
  end

  def then_i_cannot_delete_the_draft
    expect(page).to_not have_content("Delete draft")
  end
end
