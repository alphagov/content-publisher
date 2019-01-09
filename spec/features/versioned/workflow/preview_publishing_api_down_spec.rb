# frozen_string_literal: true

RSpec.feature "Previewing a document when the Publishing API is down" do
  scenario do
    given_there_is_a_document_that_failed_to_preview
    when_i_visit_the_summary_page

    and_the_publishing_api_is_down
    and_i_click_the_try_again_button
    then_i_see_an_error_message

    when_the_publishing_api_is_up
    and_i_click_the_try_again_button
    then_i_see_the_preview_page
    and_the_preview_succeeded
  end

  def given_there_is_a_document_that_failed_to_preview
    @edition = create :versioned_edition, draft: :failure
  end

  def when_i_visit_the_summary_page
    visit versioned_document_path(@edition.document)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_click_the_try_again_button
    click_on "Try again"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.preview_error.title"))
  end

  def when_the_publishing_api_is_up
    reset_executed_requests!
    @request = stub_publishing_api_put_content(@edition.content_id, {})
  end

  def then_i_see_the_preview_page
    expect(current_path).to eq versioned_preview_document_path(@edition.document)
  end

  def and_the_preview_succeeded
    expect(@request).to have_been_requested
  end
end
