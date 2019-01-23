# frozen_string_literal: true

RSpec.feature "Publishing an edition that's already published" do
  scenario do
    given_there_is_a_published_edition
    when_i_visit_the_publish_page
    and_i_publish_the_edition
    then_i_see_that_its_already_published
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def when_i_visit_the_publish_page
    visit publish_confirmation_path(@edition.document)
  end

  def and_i_publish_the_edition
    choose I18n.t!("publish.confirmation.has_been_reviewed")
    click_on "Confirm publish"
  end

  def then_i_see_that_its_already_published
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
  end
end
