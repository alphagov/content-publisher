RSpec.feature "Reorder attachments" do
  scenario "without javascript" do
    given_there_is_an_edition_with_attachments
    when_i_go_to_the_attachments_page
    and_i_click_to_reorder_the_attachments
    then_i_see_the_current_attachment_order
    and_i_change_the_numeric_positions
    then_i_see_the_order_is_updated
    and_i_see_the_timeline_entry
  end

  scenario "with javascript", js: true do
    given_there_is_an_edition_with_attachments
    when_i_go_to_the_attachments_page
    and_i_click_to_reorder_the_attachments
    then_i_see_the_current_attachment_order
    and_i_move_an_attachment_up
    then_i_see_the_order_is_updated
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition_with_attachments
    @attachment_revision1 = create(:file_attachment_revision)
    @attachment_revision2 = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: build(:document_type, attachments: "featured"),
                      file_attachment_revisions: [@attachment_revision1, @attachment_revision2])
  end

  def when_i_go_to_the_attachments_page
    visit featured_attachments_path(@edition.document)
  end

  def and_i_click_to_reorder_the_attachments
    click_on "Reorder attachments"
    stub_any_publishing_api_put_content
    stub_asset_manager_receives_an_asset
  end

  def then_i_see_the_current_attachment_order
    expect(all(".app-c-reorderable-list__title").map(&:text)).to eq([
      @attachment_revision1.title, @attachment_revision2.title
    ])
  end

  def and_i_change_the_numeric_positions
    fill_in "Position for #{@attachment_revision1.title}", with: 2
    fill_in "Position for #{@attachment_revision2.title}", with: 1
    click_on "Save attachment order"
  end

  def and_i_move_an_attachment_up
    all("button", text: "Up").last.click
    click_on "Save attachment order"
  end

  def then_i_see_the_order_is_updated
    expect(all(".gem-c-attachment__title").map(&:text)).to eq([
      @attachment_revision2.title,
      @attachment_revision1.title,
    ])
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.attachments_reordered")
  end
end
