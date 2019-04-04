# frozen_string_literal: true

RSpec.feature "Link to content data admin app data page" do
  scenario do
    given_there_is_an_edition_published_before_yesterday
    when_i_visit_the_summary_page
    then_i_see_a_link_to_the_content_data_page_for_the_document
  end

  def given_there_is_an_edition_published_before_yesterday
    document = create(:document, first_published_at: 2.days.ago)
    @edition = create(:edition, :published, document: document)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_a_link_to_the_content_data_page_for_the_document
    content_data_url_prefix = "https://content-data-admin.test.gov.uk/metrics"
    expect(page).to have_link(
      "View data about this page",
      href: content_data_url_prefix + @edition.base_path,
    )
  end
end
