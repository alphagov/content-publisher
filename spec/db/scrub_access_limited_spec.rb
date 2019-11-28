# frozen_string_literal: true

RSpec.describe "Scrub Access Limited SQL Script" do
  def execute_sql
    sql = File.read(Rails.root.join("db/scrub_access_limited.sql"))
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

  it "removes revision and status models" do
    edition = create(:edition, :access_limited)
    revision = edition.revision
    status = edition.status

    execute_sql

    expect { revision.content_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { revision.tags_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { revision.metadata_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { status.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "removes previous revisions and statuses" do
    edition = create(:edition, :access_limited)
    user = edition.created_by
    old_revision = edition.revision
    old_status = edition.status
    edition.assign_revision(build(:revision), user).save!
    edition.assign_status(:submitted_for_review, user).save!

    execute_sql

    expect { old_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { old_status.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "doesn't delete a revision that is associated with a non access limited edition" do
    access_limited_edition = create(:edition, :access_limited)
    revision = access_limited_edition.revision
    non_access_limited_edition = create(:edition, revision: revision)

    execute_sql

    expect { access_limited_edition.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { revision.reload }.not_to raise_error
    expect { non_access_limited_edition.reload }.not_to raise_error
  end

  it "deletes image revisions with associated assets and blobs" do
    image_revision = create(:image_revision, :on_asset_manager)
    create(:edition, :access_limited, image_revisions: [image_revision])
    assets = image_revision.assets
    blob = image_revision.blob_revision.blob

    execute_sql

    expect { image_revision.blob_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { image_revision.metadata_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { image_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { blob.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect(assets.reload).to be_empty
  end

  it "deletes file attachment revisions with associated assets and blobs" do
    file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
    create(:edition, :access_limited, file_attachment_revisions: [file_attachment_revision])
    blob = file_attachment_revision.blob_revision.blob

    execute_sql

    expect { file_attachment_revision.asset.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { file_attachment_revision.blob_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { file_attachment_revision.metadata_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { file_attachment_revision.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { blob.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
