# frozen_string_literal: true

RSpec.feature "Clear backdate" do
  scenario do
    given_there_is_an_editable_backdated_edition
    when_i_visit_the_summary_page
    i_can_see_the_date_the_content_has_been_backdated_to
    when_i_click_to_edit_the_backdate
    and_i_click_clear_backdate
    then_i_see_the_content_is_no_longer_backdated
  end

  def given_there_is_an_editable_backdated_edition
    @backdated_to = Time.current.yesterday
    @edition = create(:edition, backdated_to: @backdated_to)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def i_can_see_the_date_the_content_has_been_backdated_to
    backdate_title = I18n.t("documents.show.content_settings.backdate.title")
    date = @backdated_to.strftime("%-d %B %Y")
    expect(page).to have_content("#{backdate_title} #{date}")
  end

  def when_i_click_to_edit_the_backdate
    click_on "Change Backdate"
  end

  def and_i_click_clear_backdate
    @request = stub_publishing_api_put_content(@edition.content_id, {})
    click_on "Clear backdate"
  end

  def then_i_see_the_content_is_no_longer_backdated
    expect(@request).to have_been_requested

    expect(page).not_to have_content(@backdated_to.strftime("%-d %B %Y"))
    expect(page).to have_content(
      I18n.t!("documents.history.entry_types.backdate_cleared"),
    )
  end
end
