# frozen_string_literal: true

RSpec.feature "Publish without review" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_publish_without_review
    then_i_see_the_publish_succeeded

    when_i_visit_the_summary_page
    then_i_see_it_has_not_been_reviewed

    when_i_click_the_approve_button
    then_i_see_that_its_reviewed
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_publish_without_review
    click_on "Publish"
    choose I18n.t!("publish.confirmation.should_be_reviewed")
    stub_any_publishing_api_publish
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(page).to have_content(I18n.t!("publish.published.published_without_review.title"))
  end

  def then_i_see_it_has_not_been_reviewed
    expect(page).to have_content I18n.t!("user_facing_states.published_but_needs_2i.name")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.published_without_review")
    end
  end

  def when_i_click_the_approve_button
    click_on "Approve"
  end

  def then_i_see_that_its_reviewed
    expect(page).to have_content I18n.t!("documents.show.flashes.approved")
    expect(page).to have_content I18n.t!("user_facing_states.published.name")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.approved")
    end
  end
end
