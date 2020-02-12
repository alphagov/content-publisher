RSpec.feature "History mode" do
  scenario do
    given_there_is_a_past_government
    and_there_is_a_not_political_document
    and_i_am_a_managing_editor

    when_i_visit_the_summary_page
    then_i_see_that_the_content_doesnt_get_history_mode
    and_i_do_not_see_the_history_mode_banner

    when_i_click_to_change_the_status
    then_i_enable_political_status
    and_i_see_that_the_content_gets_history_mode
    and_i_see_the_timeline_entry
    and_i_do_not_see_the_history_mode_banner

    when_i_click_to_backdate_the_content
    and_i_enter_a_date_to_backdate_the_content_to
    and_i_see_the_history_mode_banner
  end

  def given_there_is_a_past_government
    @government = build(:government,
                        started_on: Time.zone.parse("2006-01-01"),
                        ended_on: Time.zone.parse("2010-01-01"))

    populate_government_bulk_data(@government)
  end

  def and_there_is_a_not_political_document
    @edition = create(:edition, :not_political)
  end

  def and_i_am_a_managing_editor
    login_as(create(:user, managing_editor: true))
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_that_the_content_doesnt_get_history_mode
    row = page.find(".govuk-summary-list__row", text: I18n.t!("documents.show.content_settings.gets_history_mode.title"))
    expect(row).to have_content(
      I18n.t!("documents.show.content_settings.gets_history_mode.false_label"),
    )
  end

  def and_i_see_that_the_content_gets_history_mode
    row = page.find(".govuk-summary-list__row", text: I18n.t!("documents.show.content_settings.gets_history_mode.title"))
    expect(row).to have_content(
      I18n.t!("documents.show.content_settings.gets_history_mode.true_label"),
    )
  end

  def when_i_click_to_change_the_status
    click_on "Change Gets history mode"
  end

  def then_i_enable_political_status
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    choose(I18n.t!("history_mode.edit.labels.political"))
    click_on "Save"
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.political_status_changed"))
  end

  def when_i_click_to_backdate_the_content
    click_on "Document summary"
    click_on "Change Backdate"
  end

  def and_i_enter_a_date_to_backdate_the_content_to
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    fill_in "backdate[date][day]", with: @government.started_on.day
    fill_in "backdate[date][month]", with: @government.started_on.month
    fill_in "backdate[date][year]", with: @government.started_on.year
    click_on "Save"
  end

  def and_i_do_not_see_the_history_mode_banner
    expect(page).not_to have_content(
      I18n.t!("documents.show.historical.title", document_type: @edition.document_type.label.downcase),
    )
  end

  def and_i_see_the_history_mode_banner
    expect(page).to have_content(
      I18n.t!("documents.show.historical.title", document_type: @edition.document_type.label.downcase),
    )
  end
end
