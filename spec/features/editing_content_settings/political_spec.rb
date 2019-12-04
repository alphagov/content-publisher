# frozen_string_literal: true

RSpec.feature "History mode" do
  scenario "not political document" do
    given_there_is_a_not_political_document
    when_i_visit_the_summary_page
    then_i_see_that_the_content_is_not_political
  end

  scenario "political document" do
    given_there_is_a_political_document
    when_i_visit_the_summary_page
    then_i_see_that_the_content_is_political
  end

  def given_there_is_a_political_document
    @edition = create(:edition, :political)
  end

  def given_there_is_a_not_political_document
    @edition = create(:edition, :not_political)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_that_the_content_is_not_political
    row = page.find(".govuk-summary-list__row", text: I18n.t!("documents.show.content_settings.political.title"))
    expect(row).to have_content(
      I18n.t!("documents.show.content_settings.political.false_label"),
    )
  end

  def then_i_see_that_the_content_is_political
    row = page.find(".govuk-summary-list__row", text: I18n.t!("documents.show.content_settings.political.title"))
    expect(row).to have_content(
      I18n.t!("documents.show.content_settings.political.true_label"),
    )
  end
end
