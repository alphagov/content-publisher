RSpec.describe "Change History tasks" do
  include ActiveJob::TestHelper

  before do
    populate_default_government_bulk_data
    stub_any_publishing_api_put_content
    allow(Tasks::EditionUpdater).to receive(:call).and_call_original
  end

  describe "change_history:show" do
    let(:change_history) do
      [
        {
          "id": SecureRandom.uuid,
          "public_timestamp": "2020-02-20T16:00:00+00:00",
          "note": "Test",
        },
      ]
    end

    before do
      allow($stdout).to receive(:puts)
      Rake::Task["change_history:show"].reenable
    end

    it "prints the change history" do
      edition = create(:edition, locale: "en", change_history: change_history)

      expect {
        Rake::Task["change_history:show"].invoke(edition.content_id)
      }.to output(
        "#{change_history.first[:id]} | 2020-02-20T16:00:00+00:00 | Test\n",
      ).to_stdout
    end

    it "prints the change history for a locale" do
      edition = create(:edition, locale: "cy", change_history: change_history)

      expect {
        ClimateControl.modify LOCALE: "cy" do
          Rake::Task["change_history:show"].invoke(edition.content_id)
        end
      }.to output(
        "#{change_history.first[:id]} | 2020-02-20T16:00:00+00:00 | Test\n",
      ).to_stdout
    end
  end

  describe "change_history:delete" do
    let(:id_to_delete) { SecureRandom.uuid }

    let(:change_history) do
      [
        {
          id: SecureRandom.uuid,
          public_timestamp: "2020-02-20T18:00:00+00:00",
          note: "Test 1",
        }, {
          id: id_to_delete,
          public_timestamp: "2020-02-20T17:00:00+00:00",
          note: "Test 2",
        }, {
          id: SecureRandom.uuid,
          public_timestamp: "2020-02-20T16:00:00+00:00",
          note: "Test 3",
        }
      ]
    end

    let(:edition) do
      create(:edition,
             locale: "en",
             change_history: change_history)
    end

    before { Rake::Task["change_history:delete"].reenable }

    it "deletes a change history entry" do
      expected_change_history = [
        change_history.first.with_indifferent_access,
        change_history.last.with_indifferent_access,
      ]

      Rake::Task["change_history:delete"].invoke(edition.content_id, id_to_delete)

      expect(edition.reload.revision.metadata_revision.change_history)
        .to eq(expected_change_history)
    end

    it "calls the edition updater" do
      Rake::Task["change_history:delete"].invoke(edition.content_id, id_to_delete)

      expect(Tasks::EditionUpdater).to have_received(:call)
    end

    it "raises an error when the change history ID does not exist" do
      expect { Rake::Task["change_history:delete"].invoke(edition.content_id, "abc123") }
        .to raise_error("No change history entry with id abc123")
    end
  end
end
