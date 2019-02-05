# frozen_string_literal: true

RSpec.feature "Unwithdraw a document" do
  scenario do
    given_there_is_a_withdrawn_document
    when_i_visit_the_summary_page
    and_i_click_on_undo_withdraw
    and_check_alert_is_displayed_and_click_yes
    then_there_is_a_redirect_to_the_document_path
  end

  def given_there_is_a_withdrawn_document
    @edition = create(:edition, :withdrawn)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_undo_withdraw
    click_on "Undo withdrawal"
  end

  def and_check_alert_is_displayed_and_click_yes
    expect(page.body).to include(I18n.t!("documents.show.unwithdraw.title"))
    click_on(I18n.t!("documents.show.unwithdraw.confirm"))
  end

  def then_there_is_a_redirect_to_the_document_path
    expect(current_path).to eq document_path(@edition.document)
  end
end
