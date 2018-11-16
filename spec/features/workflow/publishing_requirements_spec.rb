# frozen_string_literal: true

RSpec.feature "Publishing requirements" do
  include TopicsHelper

  scenario do
    given_there_is_a_document_with_issues
    when_i_visit_the_document_page
    then_i_see_a_warning_to_fix_the_issues

    when_i_try_to_publish_the_document
    then_i_see_an_error_to_fix_the_issues

    when_i_try_to_submit_the_document_for_2i
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document_with_issues
    @document = create(:document, :with_required_content_for_publishing, summary: nil)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_a_warning_to_fix_the_issues
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end

  def when_i_try_to_publish_the_document
    click_on "Publish"
  end

  def when_i_try_to_submit_the_document_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end
end
