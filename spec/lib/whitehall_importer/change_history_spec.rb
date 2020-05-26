RSpec.describe WhitehallImporter::ChangeHistory do
  describe "#for" do
    let(:first_edition) { build(:whitehall_export_edition, :superseded) }
    let(:second_edition) do
      build(:whitehall_export_edition,
            :superseded,
            change_note: "Some change",
            published_at: Time.zone.now.beginning_of_week.rfc3339)
    end
    let(:third_edition) do
      build(:whitehall_export_edition,
            :published,
            change_note: "Other change",
            published_at: Time.zone.now.beginning_of_day.rfc3339)
    end

    it "returns all the change history for a number greater than the number of editions" do
      whitehall_export = build(:whitehall_export_document,
                               editions: [first_edition, second_edition, third_edition])

      expect(described_class.new(whitehall_export).for(4)).to match([
        { "id" => anything, "note" => "Other change", "public_timestamp" => Time.zone.now.beginning_of_day.rfc3339 },
        { "id" => anything, "note" => "Some change", "public_timestamp" => Time.zone.now.beginning_of_week.rfc3339 },
      ])
    end

    it "returns the change history for the editions preceding the given edition number" do
      whitehall_export = build(:whitehall_export_document,
                               editions: [first_edition, second_edition, third_edition])

      expect(described_class.new(whitehall_export).for(3)).to match([
        { "id" => anything, "note" => "Some change", "public_timestamp" => Time.zone.now.beginning_of_week.rfc3339 },
      ])
    end

    it "returns draft edition change history if it has been previously unpublished" do
      edition = build(:whitehall_export_edition,
                      change_note: "Some change",
                      unpublishing: build(:whitehall_export_unpublishing),
                      revision_history: [build(:whitehall_export_revision_history_event,
                                               state: "published",
                                               created_at: Time.zone.now.beginning_of_day.rfc3339)])
      whitehall_export = build(:whitehall_export_document, editions: [first_edition, edition])

      expect(described_class.new(whitehall_export).for(3)).to match([
        { "id" => anything, "note" => "Some change", "public_timestamp" => Time.zone.now.beginning_of_day.rfc3339 },
      ])
    end

    it "doesn't include the first edition in change history" do
      whitehall_export = build(:whitehall_export_document, editions: [first_edition])
      expect(described_class.new(whitehall_export).for(2)).to be_empty
    end

    it "doesn't include draft editions in change history" do
      edition = build(:whitehall_export_edition)
      whitehall_export = build(:whitehall_export_document, editions: [first_edition, edition])

      expect(described_class.new(whitehall_export).for(3)).to be_empty
    end

    it "doesn't include minor change editions in change history" do
      edition = build(:whitehall_export_edition, :published, minor_change: true, change_note: "")
      whitehall_export = build(:whitehall_export_document, editions: [first_edition, edition])

      expect(described_class.new(whitehall_export).for(3)).to be_empty
    end

    it "raises if an edition has a major change but no change note" do
      edition = build(:whitehall_export_edition, :published, change_note: "")
      whitehall_export = build(:whitehall_export_document, editions: [first_edition, edition])

      expect { described_class.new(whitehall_export).for(2) }
        .to raise_error(WhitehallImporter::AbortImportError, "Edition has a major change but no change note")
    end

    it "raises if an edition has a major change but no publish event" do
      edition = build(:whitehall_export_edition,
                      :published,
                      revision_history: [build(:whitehall_export_revision_history_event)])
      whitehall_export = build(:whitehall_export_document, editions: [first_edition, edition])

      expect { described_class.new(whitehall_export).for(2) }
        .to raise_error(WhitehallImporter::AbortImportError, "Edition has a major change but no publish event")
    end
  end
end
