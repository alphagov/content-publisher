# frozen_string_literal: true

RSpec.feature "Edit tags when the Publishing API is down" do
  scenario do
    given_there_is_an_edition
    and_the_publishing_api_is_down
    when_i_visit_the_topics_page
    then_i_see_an_error_message
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_topics_page
    visit topics_path(@edition.document)
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("topics.edit.api_down"))
  end
end
