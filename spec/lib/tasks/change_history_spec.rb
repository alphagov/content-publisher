RSpec.describe "Change History tasks" do
  include ActiveJob::TestHelper

  before do
    populate_default_government_bulk_data
    stub_any_publishing_api_put_content
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
end
