# frozen_string_literal: true

RSpec.feature "Set access limit" do
  background do
    given_there_is_an_edition_in_multiple_orgs
    and_there_is_a_user_in_a_supporting_org
    and_there_is_a_user_in_some_other_org
  end

  scenario "primary organisation" do
    when_i_visit_the_summary_page
    and_i_edit_the_access_limit
    and_i_limit_to_my_organisation
    then_i_see_the_primary_org_has_access
    and_i_can_still_edit_the_edition
    and_the_supporting_user_cannot
    and_someone_in_another_org_cannot
  end

  scenario "all organisations" do
    when_i_visit_the_summary_page
    and_i_edit_the_access_limit
    and_i_limit_to_tagged_organisations
    then_i_see_tagged_orgs_have_access
    and_i_can_still_edit_the_edition
    and_the_supporting_user_can_also
    and_someone_in_another_org_cannot
  end

  def given_there_is_an_edition_in_multiple_orgs
    @supporting_org = SecureRandom.uuid
    primary_org = current_user.organisation_content_id

    stub_publishing_api_has_linkables(
      [{ "content_id" => primary_org, "internal_name" => "Primary org" },
       { "content_id" => @supporting_org, "internal_name" => "Supporting org" }],
      document_type: "organisation",
    )

    @edition = create(:edition, tags: {
      primary_publishing_organisation: [primary_org],
      organisations: [@supporting_org],
    })
  end

  def and_there_is_a_user_in_a_supporting_org
    @supporting_org_user = create(:user,
                                  permissions: [User::PRE_RELEASE_FEATURES_PERMISSION],
                                  organisation_content_id: @supporting_org)
  end

  def and_there_is_a_user_in_some_other_org
    @other_org_user = create(:user,
                             permissions: [User::PRE_RELEASE_FEATURES_PERMISSION],
                             organisation_content_id: SecureRandom.uuid)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_edit_the_access_limit
    click_on "Edit Access limiting"
  end

  def and_i_limit_to_my_organisation
    within ".govuk-radios" do
      expect(page).to have_content("Primary org")
    end

    choose I18n.t!("access_limit.edit.type.primary_organisation")
    click_on "Save"
  end

  def and_i_limit_to_tagged_organisations
    within ".govuk-radios" do
      expect(page).to have_content("Primary org", count: 2)
      expect(page).to have_content("Supporting org")
    end

    choose I18n.t!("access_limit.edit.type.tagged_organisations")
    click_on "Save"
  end

  def then_i_see_the_primary_org_has_access
    expect(page).to have_content(I18n.t!("documents.show.content_settings.access_limit.type.primary_organisation"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.access_limit_created"))
  end

  def then_i_see_tagged_orgs_have_access
    expect(page).to have_content(I18n.t!("documents.show.content_settings.access_limit.type.tagged_organisations"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.access_limit_created"))
  end

  def and_i_can_still_edit_the_edition
    visit document_path(@edition.document)
    expect(page).to have_content("Edit Access limiting")
    visit edit_document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.edit.title", title: @edition.title_or_fallback))
  end

  def and_the_supporting_user_can_also
    login_as(@supporting_org_user)
    and_i_can_still_edit_the_edition
  end

  def and_the_supporting_user_cannot
    login_as(@supporting_org_user)
    i_cannot_edit_the_edition
  end

  def and_someone_in_another_org_cannot
    login_as(@other_org_user)
    i_cannot_edit_the_edition
  end

  def i_cannot_edit_the_edition
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.forbidden.description"))
    expect(page).to have_content(I18n.t!("documents.forbidden.owner", primary_org: "Primary org"))
    visit edit_document_path(@edition.document)
    expect(page).to have_content(I18n.t!("documents.forbidden.description"))
    expect(page).to have_content(I18n.t!("documents.forbidden.owner", primary_org: "Primary org"))
  end
end
