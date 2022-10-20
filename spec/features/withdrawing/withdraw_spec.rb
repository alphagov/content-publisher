RSpec.feature "Withdraw a document" do
  scenario do
    given_there_is_a_published_edition
    and_i_am_a_managing_editor
    when_i_visit_the_summary_page
    and_i_click_on_withdraw
    and_i_fill_in_the_explanation
    and_i_confirm_the_withdrawal
    then_i_see_the_document_has_been_withdrawn
    and_i_see_the_timeline_entry
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def and_i_am_a_managing_editor
    login_as(create(:user, managing_editor: true))
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def and_i_fill_in_the_explanation
    @explanation = "An explanation using [markdown](https://www.gov.uk)"
    fill_in "public_explanation", with: @explanation
  end

  def and_i_confirm_the_withdrawal
    freeze_time do
      converted_explanation = GovspeakDocument.new(@explanation, @edition).payload_html
      body = {
        type: "withdrawal",
        explanation: converted_explanation,
        locale: @edition.locale,
        unpublished_at: Time.zone.now,
      }
      stub_publishing_api_unpublish(@edition.content_id, body:)
      click_on "Withdraw document"
    end
  end

  def then_i_see_the_document_has_been_withdrawn
    status = @edition.reload.status
    withdrawal = status.details
    document_type = @edition.document_type.label.downcase

    expect(page).to have_content(I18n.t!("user_facing_states.withdrawn.name"))
    expect(page).to have_content(I18n.t!("documents.show.withdrawn.title",
                                         document_type:,
                                         withdrawn_date: withdrawal.created_at.strftime("%-d %B %Y")))

    expect(page).to have_content(I18n.t!("documents.show.metadata.withdrawn_by") + ": #{status.created_by.name}")
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.withdrawn"))
    expect(page).to have_content(@explanation)
  end
end
