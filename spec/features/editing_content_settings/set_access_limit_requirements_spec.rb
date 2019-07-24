# frozen_string_literal: true

RSpec.feature "Set access limit with requirements issues" do
  scenario do
    given_there_is_an_edition_with_no_orgs
    when_i_try_to_set_an_access_limit
    then_i_see_an_error_to_fix_the_issue
  end

  def given_there_is_an_edition_with_no_orgs
    @edition = create(:edition)
  end

  def when_i_try_to_set_an_access_limit
    visit access_limit_path(@edition.document)
    choose(I18n.t!("access_limit.edit.type.primary_organisation"))
    click_on "Save"
  end

  def then_i_see_an_error_to_fix_the_issue
    expect(page).to have_content(I18n.t!("requirements.access_limit.no_primary_org.form_message"))
  end
end
