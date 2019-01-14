# frozen_string_literal: true

RSpec.feature "Publishing a document that's already published" do
  scenario do
    given_there_is_a_published_document
    when_i_visit_the_publish_page
    and_i_publish_the_document
    then_i_see_that_its_already_published
  end

  def given_there_is_a_published_document
    @document = create(:document, :with_live_edition)
  end

  def when_i_visit_the_publish_page
    visit publish_confirmation_path(@document)
  end

  def and_i_publish_the_document
    choose I18n.t!("publish.confirmation.has_been_reviewed")
    click_on "Confirm publish"
  end

  def then_i_see_that_its_already_published
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
  end
end
