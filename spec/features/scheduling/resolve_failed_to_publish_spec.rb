# frozen_string_literal: true

RSpec.feature "Resolve a 'failed to publish' scheduling" do
  scenario do
    given_there_is_a_edition_that_failed_to_publish
    when_i_visit_the_summary_page
    then_i_see_a_prompt
    and_i_can_edit_the_edition
    when_i_go_to_publish_the_edition
    then_i_see_it_published
  end

  def given_there_is_a_edition_that_failed_to_publish
    @edition = create(:edition, :failed_to_publish)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_a_prompt
    within(".app-c-inset-prompt") do
      expect(page).to have_content(I18n.t!("documents.show.failed_to_publish.title"))
    end
  end

  def and_i_can_edit_the_edition
    expect(page).to have_content("Edit Content")
  end

  def when_i_go_to_publish_the_edition
    click_on "Publish"
    choose I18n.t!("publish.confirmation.should_be_reviewed")
    @request = stub_publishing_api_publish(@edition.content_id,
                                           locale: @edition.locale,
                                           update_type: nil)
    click_on "Confirm publish"
  end

  def then_i_see_it_published
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("publish.published.published_without_review.title"))
  end
end
