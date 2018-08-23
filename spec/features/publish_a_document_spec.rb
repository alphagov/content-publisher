# frozen_string_literal: true

RSpec.feature "Publishing a document" do
  scenario "User publishes a document" do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_click_on_the_publish_button
    and_i_confirm_the_publishing
    then_i_see_the_publish_succeeded
  end

  def given_there_is_a_document
    @document = create(:document, publication_state: "sent_to_draft")
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_the_publish_button
    click_on "Publish"
  end

  def and_i_confirm_the_publishing
    @request = stub_publishing_api_publish(@document.content_id, update_type: "major", locale: @document.locale)
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.publish_success"))
    expect(@document.reload.publication_state).to eq("sent_to_live")
  end
end
