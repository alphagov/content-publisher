# frozen_string_literal: true

RSpec.feature "Previewing a document" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_summary_page
    and_i_click_the_preview_button
    then_i_see_the_preview_page
    and_the_preview_was_successful
  end

  def given_there_is_a_document
    @document = create :document
  end

  def when_i_visit_the_summary_page
    visit document_path(@document)
  end

  def and_i_click_the_preview_button
    stub_any_publishing_api_put_content
    click_on "Preview"
  end

  def then_i_see_the_preview_page
    expect(page).to have_content "Mobile"
    expect(page).to have_content "Desktop and tablet"
    expect(page).to have_content "Search engine snippet"
  end

  def and_the_preview_was_successful
    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)).to match a_hash_including(content_body)
    }).to have_been_requested
  end

  def content_body
    {
      "title" => @document.title,
      "document_type" => @document.document_type_schema.id,
      "description" => @document.summary,
      "update_type" => @document.update_type,
      "change_note" => @document.change_note,
      "base_path" => @document.base_path,
      "locale" => @document.locale,
    }
  end
end
