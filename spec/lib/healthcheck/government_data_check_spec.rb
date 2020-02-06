RSpec.describe Healthcheck::GovernmentDataCheck do
  let(:gov_data_check) { described_class.new }

  describe "#status" do
    context "when government data is unavailable" do
      it "returns critical" do
        expect(gov_data_check.status).to be(:critical)
      end
    end

    context "when government data is set to expire" do
      it "gives a warning" do
        populate_default_government_bulk_data
        travel_to(7.hours.from_now) do
          expect(gov_data_check.status).to be(:warning)
        end
      end
    end

    context "when everything is fine" do
      it "returns ok" do
        populate_default_government_bulk_data
        expect(gov_data_check.status).to be(:ok)
      end
    end
  end

  describe "#message" do
    context "when government data is unavailable" do
      it "displays an appropriate message" do
        expect(gov_data_check.message).to eq("No government data availible")
      end
    end

    context "when government data is set to expire" do
      it "displays an appropriate message" do
        populate_default_government_bulk_data
        travel_to(Time.zone.now + 6.5.hours)
        expect(gov_data_check.message).to eq("Government data not refreshed in 6 hours.")
      end
    end

    context "when everything is fine" do
      it "displays an appropriate message" do
        populate_default_government_bulk_data
        expect(gov_data_check.message).to be_nil
      end
    end
  end
end
