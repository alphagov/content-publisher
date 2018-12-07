# frozen_string_literal: true

RSpec.feature "Withdraw a document" do
  scenario do
    given_there_is_a_published_document
    when_i_visit_the_document_page
    and_i_click_on_withdraw
    then_i_see_that_i_can_withdraw_the_document
    when_i_fill_in_the_public_explanation
    and_click_on_withdraw_document
    then_i_see_the_document_has_been_withdrawn
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def then_i_see_that_i_can_withdraw_the_document
    expect(page).to have_content "Withdraw '#{@document.title}'"
  end

  def when_i_fill_in_the_public_explanation
    fill_in "public_explanation", with: "An explanation"
    expect(page).to have_content(I18n.t!("withdraw_document.withdraw.public_explanation.guidance_title"))
    expect(page).to have_content(I18n.t!("withdraw_document.withdraw.public_explanation.guidance"))
  end

  def and_click_on_withdraw_document
    body = { type: "withdrawal", explanation: "An explanation", locale: @document.locale }
    stub_publishing_api_unpublish(@document.content_id, body: body)
    click_on "Withdraw document"
  end

  def then_i_see_the_document_has_been_withdrawn
    timeline_entry = TimelineEntry.last
    expect(timeline_entry.entry_type).to eq("retired")
    expect(timeline_entry.document_id).to eq(@document.id)
    expect(timeline_entry.retirement.explanatory_note).to eq("An explanation")
    expect(@document.reload.live_state).to eq("retired")
    expect(page).to have_content(I18n.t!("user_facing_states.retired.name"))
  end
end
