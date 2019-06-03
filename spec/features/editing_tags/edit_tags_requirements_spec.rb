# frozen_string_literal: true

RSpec.feature "Edit tags with requirements issues" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_edit_tags_page
    and_i_submit_a_request_with_requirement_issues
    then_i_should_see_an_error_to_fix_the_issues
    and_see_my_previous_submission
  end

  def given_there_is_an_edition
    organisation_field = build(:tag_field,
                               type: "single_tag",
                               id: "primary_publishing_organisation")
    stub_publishing_api_has_linkables(
      [{ "content_id" => SecureRandom.uuid, "internal_name" => "Organisation" }],
      document_type: organisation_field.document_type,
    )
    document_type = build(:document_type, tags: [organisation_field])
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_edit_tags_page
    visit tags_path(@edition.document)
  end

  def and_i_submit_a_request_with_requirement_issues
    select "", from: "tags[primary_publishing_organisation][]"
    click_on "Save"
  end

  def then_i_should_see_an_error_to_fix_the_issues
    expect(page).to have_content(I18n.t!("requirements.primary_publishing_organisation.blank.form_message"))
  end

  def and_see_my_previous_submission
    expect(page).to have_select("tags[primary_publishing_organisation][]", selected: nil)
  end
end
