RSpec.describe "Change History tasks" do
  before do
    populate_default_government_bulk_data
    stub_any_publishing_api_put_content
    allow(EditionUpdater).to receive(:call).and_call_original
  end

  describe "change_history:show" do
    let(:change_history) do
      [
        {
          "id" => SecureRandom.uuid,
          "public_timestamp" => "2020-02-20T16:00:00+00:00",
          "note" => "Change note",
        },
      ]
    end

    before do
      allow($stdout).to receive(:puts)
      Rake::Task["change_history:show"].reenable
    end

    it "prints the change history" do
      edition = create(:edition, locale: "en", change_history:)

      expect {
        Rake::Task["change_history:show"].invoke(edition.content_id)
      }.to output(
        "#{change_history.first['id']} | 2020-02-20T16:00:00+00:00 | Change note\n",
      ).to_stdout
    end

    it "prints the change history for a specific locale" do
      edition = create(:edition, locale: "cy", change_history:)

      expect {
        ClimateControl.modify LOCALE: "cy" do
          Rake::Task["change_history:show"].invoke(edition.content_id)
        end
      }.to output(
        "#{change_history.first['id']} | 2020-02-20T16:00:00+00:00 | Change note\n",
      ).to_stdout
    end
  end

  describe "change_history:delete" do
    let(:id_to_delete) { SecureRandom.uuid }

    let(:change_history) do
      [
        {
          "id" => SecureRandom.uuid,
          "public_timestamp" => "2020-02-20T18:00:00+00:00",
          "note" => "First change note",
        },
        {
          "id" => id_to_delete,
          "public_timestamp" => "2020-02-20T17:00:00+00:00",
          "note" => "Second change note",
        },
        {
          "id" => SecureRandom.uuid,
          "public_timestamp" => "2020-02-20T16:00:00+00:00",
          "note" => "Third change note",
        },
      ]
    end

    let(:edition) { create(:edition, locale: "en", change_history:) }

    before { Rake::Task["change_history:delete"].reenable }

    it "deletes a change history entry" do
      expected_change_history = [change_history.first, change_history.last]

      Rake::Task["change_history:delete"].invoke(edition.content_id, id_to_delete)

      expect(edition.reload.change_history)
        .to eq(expected_change_history)
    end

    it "calls the edition updater" do
      Rake::Task["change_history:delete"].invoke(edition.content_id, id_to_delete)

      expect(EditionUpdater).to have_received(:call)
    end

    it "raises an error when the change history ID does not exist" do
      expect { Rake::Task["change_history:delete"].invoke(edition.content_id, "abc123") }
        .to raise_error("No change history entry with id abc123")
    end
  end

  describe "change_history:edit" do
    let(:id_to_edit) { SecureRandom.uuid }

    let(:change_history) do
      [
        {
          "id" => SecureRandom.uuid,
          "public_timestamp" => "2020-02-20T18:00:00+00:00",
          "note" => "First change note",
        },
        {
          "id" => id_to_edit,
          "public_timestamp" => "2020-02-20T17:00:00+00:00",
          "note" => "Second change note",
        },
        {
          "id" => SecureRandom.uuid,
          "public_timestamp" => "2020-02-20T16:00:00+00:00",
          "note" => "Third change note",
        },
      ]
    end

    let(:edition) { create(:edition, locale: "en", change_history:) }

    before { Rake::Task["change_history:edit"].reenable }

    it "updates a change history entry note" do
      ClimateControl.modify NOTE: "Updated second change note" do
        Rake::Task["change_history:edit"].invoke(edition.content_id, id_to_edit)

        expect(edition.reload.change_history.second["note"]).to eq("Updated second change note")
      end
    end

    it "calls the edition updater" do
      ClimateControl.modify NOTE: "Updated second change note" do
        Rake::Task["change_history:edit"].invoke(edition.content_id, id_to_edit)

        expect(EditionUpdater).to have_received(:call)
      end
    end

    it "raises an error when no note is supplied" do
      ClimateControl.modify NOTE: "" do
        expect { Rake::Task["change_history:edit"].invoke(edition.content_id, "abc123") }
          .to raise_error("Expected a note")
      end
    end

    it "raises an error when the change history ID does not exist" do
      ClimateControl.modify NOTE: "Updated change note" do
        expect { Rake::Task["change_history:edit"].invoke(edition.content_id, "abc123") }
          .to raise_error("No change history entry with id abc123")
      end
    end
  end

  describe "change_history:add" do
    let(:change_history) do
      [
        {
          "id" => SecureRandom.uuid,
          "public_timestamp" => "2020-02-20T16:00:00+00:00",
          "note" => "First change note",
        },
      ]
    end

    let(:edition) { create(:edition, locale: "en", change_history:) }

    before { Rake::Task["change_history:add"].reenable }

    it "adds a change history entry note" do
      ClimateControl.modify NOTE: "New change note", TIMESTAMP: "2020-10-22 09:30" do
        Rake::Task["change_history:add"].invoke(edition.content_id)

        expect(edition.reload.change_history)
          .to include(a_hash_including("note" => "New change note",
                                       "public_timestamp" => "2020-10-22T09:30:00+01:00"))
      end
    end

    it "calls the edition updater" do
      ClimateControl.modify NOTE: "New change note", TIMESTAMP: "2020-10-22 09:30" do
        Rake::Task["change_history:add"].invoke(edition.content_id)

        expect(EditionUpdater).to have_received(:call)
      end
    end

    it "adds a change history entry note in the correct order" do
      ClimateControl.modify NOTE: "New change note", TIMESTAMP: "2019-01-01 00:00" do
        Rake::Task["change_history:add"].invoke(edition.content_id)

        change_notes = edition.reload.change_history.map { |c| c["note"] }

        expect(change_notes).to eq(["First change note", "New change note"])
      end
    end

    it "raises an error when no note is supplied" do
      ClimateControl.modify NOTE: "" do
        expect { Rake::Task["change_history:add"].invoke(edition.content_id, "abc123") }
          .to raise_error("Expected a note")
      end
    end

    it "raises an error when no timestamp is supplied" do
      ClimateControl.modify NOTE: "New change note", TIMESTAMP: "" do
        expect { Rake::Task["change_history:add"].invoke(edition.content_id, "abc123") }
          .to raise_error("Expected a timestamp")
      end
    end
  end
end
