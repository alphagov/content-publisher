# frozen_string_literal: true

RSpec.feature "Publish requirements when the Publishing API is down" do
  include TopicsHelper

  scenario do
    given_there_is_an_edition
    when_the_publishing_api_is_down
    then_i_do_not_see_warnings_that_require_it

    when_i_try_to_publish_the_edition
    then_i_see_an_error_to_prevent_publishing

    when_i_try_to_submit_for_2i
    then_i_see_an_error_to_prevent_submission
  end

  def given_there_is_an_edition
    document_type = build(:document_type, topics: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_the_publishing_api_is_down
    publishing_api_isnt_available
    visit document_path(@edition.document)
  end

  def then_i_do_not_see_warnings_that_require_it
    within(".app-c-inset-prompt") do
      expect(page).to_not have_content(I18n.t!("requirements.topics.none.summary_message"))
      expect(page).to have_content(I18n.t!("requirements.summary.blank.summary_message"))
    end
  end

  def when_i_try_to_publish_the_edition
    click_on "Publish"
  end

  def when_i_try_to_submit_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_an_error_to_prevent_publishing
    expect(page).to have_content(I18n.t!("documents.show.flashes.publish_error.title"))
  end

  def then_i_see_an_error_to_prevent_submission
    expect(page).to have_content(I18n.t!("documents.show.flashes.2i_error.title"))
  end
end
