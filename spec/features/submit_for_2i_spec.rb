# frozen_string_literal: true

RSpec.feature "2i" do
  scenario "User submits document for 2i" do
    given_there_is_a_document_in_draft
    when_i_visit_the_document
    and_i_click_submit_for_2i
    then_i_see_that_the_content_has_been_submitted
  end

  def given_there_is_a_document_in_draft
    @document = create(:document, publication_state: "sent_to_draft")
  end

  def when_i_visit_the_document
    visit document_path(@document)
  end

  def and_i_click_submit_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_that_the_content_has_been_submitted
    expect(page).to have_content "Content has been submitted for 2i review"
  end
end
