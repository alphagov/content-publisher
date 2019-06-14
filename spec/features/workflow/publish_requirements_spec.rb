# frozen_string_literal: true

RSpec.feature "Publish requirements" do
  include TopicsHelper

  scenario do
    given_there_is_an_edition_with_issues
    when_i_visit_the_summary_page
    then_i_see_a_warning_to_fix_the_issues

    when_i_try_to_publish_the_edition
    then_i_see_an_error_to_fix_the_issues

    when_i_try_to_submit_for_2i
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_an_edition_with_issues
    @edition = create(:edition, :publishable, summary: nil)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_a_warning_to_fix_the_issues
    within(".app-c-inset-prompt") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end

  def when_i_try_to_publish_the_edition
    click_on "Publish"
  end

  def when_i_try_to_submit_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end
end
