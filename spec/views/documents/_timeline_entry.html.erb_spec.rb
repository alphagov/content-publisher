# frozen_string_literal: true

RSpec.describe "documents/_timeline_entry.html.erb" do
  it "shows a timeline entry without an author" do
    timeline_entry = create(:timeline_entry,
                            created_by: nil)
    render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
    expect(rendered).not_to have_content(I18n.t!("documents.history.by"))
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.created"))
  end

  it "shows a timeline entry with an author" do
    timeline_entry = create(:timeline_entry)
    render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
    expect(rendered).to have_content(I18n.t!("documents.history.by") + " John Smith")
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.created"))
  end

  it "shows a timeline entry with content" do
    timeline_entry = create(:timeline_entry,
                            entry_type: :internal_note,
                            details: create(:internal_note))
    render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
    within(".app-timeline-entry__content") do
      expect(rendered).to have_content("Amazing internal note")
    end
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.internal_note"))
  end

  it "shows a Whitehall timeline entry without an author" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :new_edition,
                            created_by: nil)
    render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
    expect(rendered).not_to have_content(I18n.t!("documents.history.by"))
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.whitehall_migration.new_edition"))
  end

  it "shows a Whitehall timeline entry with an author" do
    timeline_entry = create(:timeline_entry,
                            :whitehall_imported,
                            whitehall_entry_type: :new_edition)

    render partial: "documents/timeline_entry", locals: { entry: timeline_entry }
    expect(rendered).to have_content(I18n.t!("documents.history.by") + " John Smith")
    expect(rendered).to have_content(I18n.t!("documents.history.entry_types.whitehall_migration.new_edition"))
  end
end
