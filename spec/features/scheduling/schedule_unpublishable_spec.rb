# frozen_string_literal: true

RSpec.feature "Schedule an unpublishable edition" do
  scenario do
    given_there_is_an_edition_with_issues
    when_i_go_to_schedule_the_edition
    then_i_am_sent_back_to_the_summary_page
    and_i_can_see_issues
  end

  def given_there_is_an_edition_with_issues
    @edition = create(:edition, :schedulable, summary: "")
  end

  def when_i_go_to_schedule_the_edition
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def then_i_am_sent_back_to_the_summary_page
    expect(page).to have_current_path(document_path(@edition.document))
  end

  def and_i_can_see_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end
end
