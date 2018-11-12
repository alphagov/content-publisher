# frozen_string_literal: true

RSpec.feature "Publishing requirements" do
  scenario do
    given_there_is_a_document
    when_the_document_has_missing_contents
    then_i_see_a_hint_to_enter_the_contents

    when_the_document_needs_a_change_note
    then_i_see_a_hint_to_enter_a_change_note

    when_i_try_to_publish_the_document
    then_i_see_an_error_to_enter_the_contents
    and_i_see_an_error_to_enter_a_change_note

    when_i_try_to_submit_the_document_for_2i
    then_i_see_an_error_to_enter_the_contents
    and_i_see_an_error_to_enter_a_change_note
  end

  def given_there_is_a_document
    field_schema = build(:field_schema, id: "body", type: "govspeak")
    document_type_schema = build(:document_type_schema, contents: [field_schema])
    @document = create(:document, document_type: document_type_schema.id)
  end

  def when_the_document_has_missing_contents
    visit document_path(@document)
    click_on "Change Content"
    fill_in "document[summary]", with: ""
    fill_in "document[contents][body]", with: ""
    stub_any_publishing_api_put_content
    click_on "Save"
  end

  def when_the_document_needs_a_change_note
    @document.update!(has_live_version_on_govuk: true)
    click_on "Change Content"
    fill_in "document[change_note]", with: ""
    stub_any_publishing_api_put_content
    click_on "Save"
  end

  def then_i_see_a_hint_to_enter_the_contents
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t!("publishing_requirements.summary_presence"))
      expect(page).to have_content(I18n.t!("publishing_requirements.body_presence"))
    end
  end

  def then_i_see_a_hint_to_enter_a_change_note
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t!("publishing_requirements.change_note_presence"))
    end
  end

  def when_i_try_to_publish_the_document
    click_on "Publish"
  end

  def when_i_try_to_submit_the_document_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_an_error_to_enter_the_contents
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("publishing_requirements.summary_presence"))
      expect(page).to have_content(I18n.t!("publishing_requirements.body_presence"))
    end
  end

  def and_i_see_an_error_to_enter_a_change_note
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("publishing_requirements.change_note_presence"))
    end
  end
end
