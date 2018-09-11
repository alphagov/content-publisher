# frozen_string_literal: true

RSpec.feature "Showing a document summary" do
  scenario "User views a document that has no creator" do
    given_there_is_a_document_with_no_creator
    when_i_visit_the_document_page
    the_document_creator_is_shown_as_unknown
  end

  def given_there_is_a_document_with_no_creator
    @document = create(:document, creator_id: nil)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def the_document_creator_is_shown_as_unknown
    within("div.app-c-metadata") do
      expect(page).to have_content(I18n.t("documents.show.metadata.created_by") +
        ": " + I18n.t("documents.show.metadata.unknown_creator"))
    end
  end
end
