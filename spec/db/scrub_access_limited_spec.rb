# frozen_string_literal: true

RSpec.describe "Scrub Access Limited SQL Script" do
  def execute_sql
    sql = File.read(Rails.root.join("db", "scrub_access_limited.sql"))
    ActiveRecord::Base.connection.execute(sql)
  end

  let(:document) { create(:document) }

  it "replaces an access limited draft with the live one" do
    current_edition = create(:edition, :access_limited, document: document)
    live_edition = create(:edition,
                          :published,
                          current: false,
                          document: current_edition.document)

    expect(document.reload.current_edition).to eq(current_edition)

    execute_sql

    expect(document.reload.current_edition).to eq(live_edition)
    expect { current_edition.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "leaves no editions for a document with only an active limited draft" do
    create(:edition, :access_limited, document: document)

    expect { execute_sql }
      .to change { document.editions.count }
      .to(0)
  end

  it "doesn't affect editions that aren't access limited" do
    create(:edition, document: document)

    expect { execute_sql }
      .not_to change { document.editions.count }
      .from(1)
  end

  it "removes associated internal notes" do
    edition = create(:edition, :access_limited)
    internal_note = create(:internal_note, edition: edition)

    execute_sql

    expect { internal_note.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "removes associated timeline entries" do
    edition = create(:edition, :access_limited)
    timeline_entry = create(:timeline_entry, edition: edition)

    execute_sql

    expect { timeline_entry.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
