# frozen_string_literal: true

RSpec.describe "documents/history/_whitehall_entry.html.erb" do
  it "shows an imported timeline entry without an author" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :new_edition,
                            created_by: nil)
    render partial: "documents/history/whitehall_entry", locals: { entry: timeline_entry }
    expect(rendered).not_to have_content(I18n.t!("documents.history.by"))
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.whitehall_migration.new_edition"))
  end

  it "shows an imported timeline entry with an author" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :new_edition)

    render partial: "documents/history/whitehall_entry", locals: { entry: timeline_entry }
    expect(rendered).to have_content(I18n.t!("documents.history.by") + " John Smith")
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.whitehall_migration.new_edition"))
  end
end
