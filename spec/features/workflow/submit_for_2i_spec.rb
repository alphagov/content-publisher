# frozen_string_literal: true

RSpec.feature "2i" do
  scenario do
    given_there_is_a_document_in_draft
    when_i_visit_the_document
    and_i_click_submit_for_2i
    then_i_see_the_document_is_submitted
    and_i_see_a_link_to_the_document

    when_i_edit_the_document
    then_i_see_it_is_still_in_review
  end

  def given_there_is_a_document_in_draft
    @document = create(:document, :with_required_content_for_publishing, publication_state: "sent_to_draft")
  end

  def when_i_visit_the_document
    visit document_path(@document)
  end

  def and_i_click_submit_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_the_document_is_submitted
    expect(page).to have_content I18n.t!("documents.show.flashes.submitted_for_review.title")
    expect(page).to have_content I18n.t!("user_facing_states.submitted_for_review.name")

    within find(".app-timeline-entry:first") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.submitted")
    end
  end

  def then_i_see_it_is_still_in_review
    expect(page).to have_content I18n.t!("user_facing_states.submitted_for_review.name")
  end

  def and_i_see_a_link_to_the_document
    review_url = find_field(I18n.t!("documents.show.flashes.submitted_for_review.label")).value
    expect(review_url).to match(document_url(@document))
  end

  def when_i_edit_the_document
    stub_any_publishing_api_put_content
    click_on "Change Content"
    fill_in "document[title]", with: "a new title"
    click_on "Save"
  end
end
