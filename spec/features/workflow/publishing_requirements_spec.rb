# frozen_string_literal: true

RSpec.feature "Publishing requirements" do
  include TopicsHelper

  scenario do
    given_there_is_a_document
    when_the_document_has_issues_to_fix
    then_i_see_a_warning_to_fix_the_issues

    when_i_try_to_publish_the_document
    then_i_see_an_error_to_fix_the_issues

    when_i_try_to_submit_the_document_for_2i
    then_i_see_an_error_to_fix_the_issues
  end

  def given_there_is_a_document
    field_schema = build(:field_schema, id: "body", type: "govspeak")
    document_type_schema = build(:document_type_schema, contents: [field_schema], topics: true)
    @document = create(:document, document_type: document_type_schema.id)
  end

  def when_the_document_has_issues_to_fix
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {},
      "version" => 3,
    )

    publishing_api_has_taxonomy
    @document.update!(has_live_version_on_govuk: true)
    visit document_path(@document)
  end

  def then_i_see_a_warning_to_fix_the_issues
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t!("publishing_requirements.no_summary"))
      expect(page).to have_content(I18n.t!("publishing_requirements.no_content_body"))
      expect(page).to have_content(I18n.t!("publishing_requirements.no_change_note"))
      expect(page).to have_content(I18n.t!("publishing_requirements.no_topics"))
    end
  end

  def when_i_try_to_publish_the_document
    click_on "Publish"
  end

  def when_i_try_to_submit_the_document_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_an_error_to_fix_the_issues
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("publishing_requirements.no_summary"))
      expect(page).to have_content(I18n.t!("publishing_requirements.no_content_body"))
      expect(page).to have_content(I18n.t!("publishing_requirements.no_change_note"))
      expect(page).to have_content(I18n.t!("publishing_requirements.no_topics"))
    end
  end
end
