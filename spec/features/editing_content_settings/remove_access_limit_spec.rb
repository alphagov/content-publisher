# frozen_string_literal: true

RSpec.feature "Remove access limit" do
  scenario do
    given_there_is_an_access_limited_edition
    and_there_is_a_user_in_some_other_org
    when_i_visit_the_summary_page
    and_i_go_to_edit_the_access_limit
    and_i_remove_the_access_limit
    then_i_see_the_access_limit_is_removed
    and_the_other_user_can_edit_the_edition
  end

  def given_there_is_an_access_limited_edition
    @edition = create(:edition, :access_limited, created_by: current_user)
    primary_org = current_user.organisation_content_id

    stub_publishing_api_has_linkables(
      [{ "content_id" => primary_org, "internal_name" => "Primary org" }],
      document_type: "organisation",
    )
  end

  def and_there_is_a_user_in_some_other_org
    @other_org_user = create(:user,
                             permissions: [User::PRE_RELEASE_FEATURES_PERMISSION],
                             organisation_content_id: SecureRandom.uuid)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_go_to_edit_the_access_limit
    click_on "Edit Access limit"
  end

  def and_i_remove_the_access_limit
    choose I18n.t!("access_limit.edit.no_access_limit")
    click_on "Save"
  end

  def then_i_see_the_access_limit_is_removed
    expect(page).to have_content(I18n.t!("documents.show.content_settings.access_limit.no_access_limit"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.access_limit_removed"))
  end

  def and_the_other_user_can_edit_the_edition
    login_as(@other_org_user)
    visit document_path(@edition.document)
    expect(page).to have_content("Edit Access limiting")
  end
end
