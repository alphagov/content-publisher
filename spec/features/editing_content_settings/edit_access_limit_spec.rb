RSpec.describe "Edit access limit" do
  it do
    given_there_is_an_access_limited_edition
    when_i_visit_the_summary_page
    and_i_go_to_edit_the_access_limit
    then_i_see_the_current_access_limit

    when_i_edit_the_access_limit_type
    then_i_see_the_access_limit_is_updated
    and_i_see_the_access_limit_updated_timeline_entry

    when_i_go_to_edit_the_access_limit
    and_i_remove_the_access_limit
    then_i_see_the_access_limit_is_removed
    and_i_see_the_access_limit_removed_timeline_entry
  end

  def given_there_is_an_access_limited_edition
    supporting_org = SecureRandom.uuid
    primary_org = current_user.organisation_content_id

    stub_publishing_api_has_linkables(
      [{ "content_id" => primary_org, "internal_name" => "Primary org" },
       { "content_id" => supporting_org, "internal_name" => "Supporting org" }],
      document_type: "organisation",
    )

    @edition = create(
      :edition,
      :access_limited,
      limit_type: :tagged_organisations,
      tags: {
        primary_publishing_organisation: [primary_org],
        organisations: [supporting_org],
      },
    )
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_go_to_edit_the_access_limit
    click_on "Change Access limiting"
  end

  def then_i_see_the_current_access_limit
    radio_text = I18n.t!("access_limit.edit.type.tagged_organisations")
    expect(find_field(radio_text)).to be_checked

    within ".govuk-radios" do
      expect(page).to have_content("Primary org", count: 2)
      expect(page).to have_content("Supporting org")
    end
  end

  def when_i_edit_the_access_limit_type
    stub_any_publishing_api_put_content
    choose(I18n.t!("access_limit.edit.type.primary_organisation"))
    click_on "Save"
  end

  def then_i_see_the_access_limit_is_updated
    expect(page).to have_content(I18n.t!("documents.show.content_settings.access_limit.type.primary_organisation"))
  end

  def and_i_see_the_access_limit_updated_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.access_limit_updated"))
  end

  def when_i_go_to_edit_the_access_limit
    click_on "Document summary"
    click_on "Change Access limiting"
  end

  def and_i_remove_the_access_limit
    choose I18n.t!("access_limit.edit.no_access_limit")
    click_on "Save"
  end

  def then_i_see_the_access_limit_is_removed
    expect(page).to have_content(I18n.t!("documents.show.content_settings.access_limit.no_access_limit"))
  end

  def and_i_see_the_access_limit_removed_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.access_limit_removed"))
  end
end
