# frozen_string_literal: true

RSpec.feature "Showing a document summary" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    then_i_see_the_document_summary
  end

  def given_there_is_a_document
    @edition = create(:edition,
                      title: "Title",
                      summary: "Summary",
                      last_edited_at: 2.weeks.ago)
  end

  def when_i_visit_the_document_page
    visit document_path(@edition.document)
  end

  def then_i_see_the_document_summary
    expect(page).to have_content(@edition.title)
    expect(page).to have_content(@edition.summary)

    within("div.app-c-metadata") do
      expect(page).to have_content(@edition.document.created_at.strftime("%l:%M%P on %d %B %Y"))
      expect(page).to have_content(@edition.last_edited_at.strftime("%l:%M%P on %d %B %Y"))
    end
  end
end
