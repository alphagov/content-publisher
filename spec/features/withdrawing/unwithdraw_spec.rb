RSpec.feature "Unwithdraw" do
  scenario do
    given_there_is_a_withdrawn_edition
    and_i_am_a_managing_editor
    when_i_visit_the_summary_page
    and_i_undo_the_withdrawal
    then_i_see_the_edition_is_unwithdrawn
    and_i_see_the_timeline_entry
  end

  def given_there_is_a_withdrawn_edition
    published_status = build(:status, :published_but_needs_2i)
    withdrawal = build(:withdrawal, published_status: published_status)
    @edition = create(:edition, :withdrawn, withdrawal: withdrawal)
  end

  def and_i_am_a_managing_editor
    login_as(create(:user, managing_editor: true))
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_undo_the_withdrawal
    @republish_request = stub_publishing_api_republish(@edition.content_id, {})
    click_on "Undo withdrawal"
    click_on "Yes, undo withdrawal"
  end

  def then_i_see_the_edition_is_unwithdrawn
    expect(@republish_request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.published_but_needs_2i.name"))
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.unwithdrawn"))
  end
end
