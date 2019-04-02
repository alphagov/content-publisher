# frozen_string_literal: true

RSpec.feature "Publish without confirming a review status" do
  scenario do
    given_there_is_an_edition_in_draft
    when_i_visit_the_summary_page
    and_try_and_publish_without_selecting_a_review_status
    then_an_error_is_displayed
  end

  def given_there_is_an_edition_in_draft
    @edition = create(:edition, :publishable)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_try_and_publish_without_selecting_a_review_status
    click_on "Publish"
    click_on "Confirm publish"
  end

  def then_an_error_is_displayed
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.review_status.not_selected.form_message"))
    end
  end
end
