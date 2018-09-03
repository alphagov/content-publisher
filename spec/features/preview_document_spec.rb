# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Preview a document" do
  scenario "User previews a document" do
    given_there_is_a_document_in_draft
    when_i_visit_the_preview_page
    then_i_see_the_previews
  end

  def given_there_is_a_document_in_draft
    @document = create(:document, publication_state: "sent_to_draft", base_path: "/foo/foo", content_id: "d2547c42-8ed3-49f5-baeb-6112f98c2bf9")
  end

  def when_i_visit_the_preview_page
    visit document_path(@document)
    click_on I18n.t("documents.show.actions.view_draft")
  end

  def then_i_see_the_previews
    # Core functionality of the preview should be tested in the component view test
    expect(page).to have_content "Mobile"
    expect(page).to have_content "Desktop and tablet"
    expect(page).to have_content "Search engine snippet"
  end
end
