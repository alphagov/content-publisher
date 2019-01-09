# frozen_string_literal: true

RSpec.feature "Previewing a document" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_summary_page
    and_i_click_the_preview_button
    then_i_see_the_preview_page
  end

  def given_there_is_a_document
    @document = create :versioned_document, :with_current_edition
  end

  def when_i_visit_the_summary_page
    visit versioned_document_path(@document)
  end

  def and_i_click_the_preview_button
    click_on "Preview"
  end

  def then_i_see_the_preview_page
    expect(page).to have_content "Mobile"
    expect(page).to have_content "Desktop and tablet"
    expect(page).to have_content "Search engine snippet"
  end
end
