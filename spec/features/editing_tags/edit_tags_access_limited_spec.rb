# frozen_string_literal: true

RSpec.feature "Edit tags of access limited edition" do
  scenario do
    given_there_is_an_access_limited_edition
    when_i_visit_the_edit_tags_page
    then_i_see_a_warning_against_editing_organisations
  end

  def given_there_is_an_access_limited_edition
    primary_org = current_user.organisation_content_id

    organisation_field = build(:tag_field,
                               type: "single_tag",
                               id: "primary_publishing_organisation")

    stub_publishing_api_has_linkables(
      [{ "content_id" => primary_org, "internal_name" => "Organisation" }],
      document_type: organisation_field.document_type,
    )
    document_type = build(:document_type, tags: [organisation_field])
    @edition = create(:edition,
                      :access_limited,
                      document_type_id: document_type.id,
                      created_by: current_user)
  end

  def when_i_visit_the_edit_tags_page
    visit tags_path(@edition.document)
  end

  def then_i_see_a_warning_against_editing_organisations
    expect(page).to have_content(I18n.t!("tags.edit.organisation_warning"))
  end
end
