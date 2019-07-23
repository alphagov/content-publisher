# frozen_string_literal: true

RSpec.feature "Edit access limit when the Publishing API is down" do
  background do
    given_there_is_an_access_limited_edition
    and_the_publishing_api_is_down
  end

  scenario "user has access" do
    when_i_visit_the_summary_page
    and_i_go_to_edit_the_access_limit
    then_i_see_an_error_message
  end

  scenario "user does not have access" do
    given_i_am_a_user_in_some_other_org
    when_i_visit_the_summary_page
    then_i_see_i_cannot_edit_the_edition
  end

  def given_there_is_an_access_limited_edition
    @edition = create(:edition, :access_limited, created_by: current_user)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def given_i_am_a_user_in_some_other_org
    other_org_user = create(:user, organisation_content_id: "other-org")
    login_as(other_org_user)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_go_to_edit_the_access_limit
    click_on "Edit Access limiting"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("access_limit.edit.api_down"))
  end

  def then_i_see_i_cannot_edit_the_edition
    expect(page).to have_content(I18n.t!("documents.forbidden.description"))
  end
end
