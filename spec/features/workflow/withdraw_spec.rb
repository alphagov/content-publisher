# frozen_string_literal: true

RSpec.feature "Withdraw a document" do
  scenario do
    given_there_is_a_published_edition
    and_i_have_the_managing_editor_permission
    when_i_visit_the_summary_page
    and_i_click_on_withdraw
    then_i_see_that_i_can_withdraw_the_document
    when_i_fill_in_the_public_explanation
    and_click_on_withdraw_document
    then_i_see_the_document_has_been_withdrawn
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def and_i_click_on_withdraw
    click_on "Withdraw"
  end

  def then_i_see_that_i_can_withdraw_the_document
    expect(page).to have_content "Withdraw '#{@edition.title}'"
  end

  def when_i_fill_in_the_public_explanation
    @explanation = "An explanation using [markdown](https://www.gov.uk)"
    fill_in "public_explanation", with: @explanation
    expect(page).to have_content(I18n.t!("withdraw.new.public_explanation.guidance_title"))
  end

  def and_click_on_withdraw_document
    converted_explanation = GovspeakDocument.new(@explanation, @edition).payload_html
    body = { type: "withdrawal", explanation: converted_explanation, locale: @edition.locale }
    stub_publishing_api_unpublish(@edition.content_id, body: body)
    click_on "Withdraw document"
  end

  def then_i_see_the_document_has_been_withdrawn
    status = @edition.reload.status
    withdrawal = status.details
    document_type = @edition.document.document_type.label.downcase

    expect(page).to have_content(I18n.t!("user_facing_states.withdrawn.name"))
    expect(page).to have_content(I18n.t!("documents.show.withdrawn.title",
                                         document_type: document_type,
                                         withdrawn_date: withdrawal.created_at.strftime("%d %B %Y")))
    expect(page).to have_content(@explanation)
    expect(page).to have_content(I18n.t!("documents.show.metadata.withdrawn_by") + ": #{status.created_by.name}")
  end
end
