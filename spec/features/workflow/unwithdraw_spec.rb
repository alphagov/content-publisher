# frozen_string_literal: true

RSpec.feature "Unwithdraw a document" do
  scenario do
    given_there_is_a_withdrawn_document
    and_i_am_a_managing_editor
    when_i_visit_the_summary_page
    then_i_see_the_documents_withdrawn_banner
    and_i_click_on_undo_withdrawal_and_confirm
    then_i_see_the_document_is_now_unwithdrawn
  end

  def given_there_is_a_withdrawn_document
    @withdrawn_edition = create(:edition, :withdrawn)
  end

  def and_i_am_a_managing_editor
    login_as(create(:user, :managing_editor))
  end

  def when_i_visit_the_summary_page
    visit document_path(@withdrawn_edition.document)
  end

  def then_i_see_the_documents_withdrawn_banner
    @withdrawal = @withdrawn_edition.status.details

    expect(page.body).to include(I18n.t!("documents.show.withdrawn.title",
                                         document_type: @withdrawn_edition.document_type.label.downcase,
                                         withdrawn_date: @withdrawal.created_at.strftime("%-d %B %Y")))
  end

  def and_i_click_on_undo_withdrawal_and_confirm
    @request = stub_publishing_api_republish(@withdrawn_edition.content_id, {})

    click_on "Undo withdrawal"
    click_on(I18n.t!("documents.show.unwithdraw.confirm"))
  end

  def then_i_see_the_document_is_now_unwithdrawn
    @withdrawn_edition.reload

    expect(@request).to have_been_requested
    expect(@withdrawn_edition).to be_published
    expect(@withdrawn_edition.timeline_entries.last.entry_type).to eq("unwithdrawn")

    expect(page.body).to_not include(I18n.t!("documents.show.withdrawn.title",
                                             document_type: @withdrawn_edition.document_type.label.downcase,
                                             withdrawn_date: @withdrawal.created_at.strftime("%-d %B %Y")))
  end
end
