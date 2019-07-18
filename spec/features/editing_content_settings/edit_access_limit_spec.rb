# frozen_string_literal: true

RSpec.feature "Edit access limit" do
  scenario do
    given_there_is_an_access_limited_edition
    when_i_visit_the_summary_page
    and_i_go_to_edit_the_access_limit
    then_i_see_the_current_access_limit
    when_i_edit_the_access_limit_type
    then_i_see_the_access_limit_is_updated
  end

  def given_there_is_an_access_limited_edition
    @edition = create(:edition, :access_limited, created_by: current_user)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_go_to_edit_the_access_limit
    click_on "Edit Access limiting"
  end

  def then_i_see_the_current_access_limit
    radio_text = I18n.t!("access_limit.edit.type.tagged_organisations")
    expect(find_field(radio_text)).to be_checked
  end

  def when_i_edit_the_access_limit_type
    choose(I18n.t!("access_limit.edit.type.primary_organisation"))
    click_on "Save"
  end

  def then_i_see_the_access_limit_is_updated
    expect(page).to have_content(I18n.t!("documents.show.content_settings.access_limit.type.primary_organisation"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.access_limit_updated"))
  end
end
