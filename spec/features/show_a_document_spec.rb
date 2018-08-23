# frozen_string_literal: true

RSpec.feature "Showing a document summary" do
  scenario "User view a document" do
    given_there_is_a_document
    when_i_visit_the_document_page
    then_i_see_the_document_summary
  end

  def given_there_is_a_document
    @document = create(:document, title: "Title", summary: "Summary", created_at: 1.month.ago)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_the_document_summary
    expect(page).to have_content(@document.title)
    expect(page).to have_content(@document.summary)
    expect(page).to have_content(@document.created_at.strftime("%l:%M%P on %d %B %Y"))
    expect(page).to have_content(@document.updated_at.strftime("%l:%M%P on %d %B %Y"))
  end
end
