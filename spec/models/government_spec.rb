# frozen_string_literal: true

RSpec.describe Government do
  describe ".all" do
    it "returns a collection of governments" do
      expect(Government.all).not_to be_empty
      expect(Government.all).to all be_a(Government)
    end
  end

  describe ".find" do
    let(:content_id) { SecureRandom.uuid }
    let(:government) { build(:government, content_id: content_id) }
    before { allow(Government).to receive(:all).and_return([government]) }

    it "finds a government by content id" do
      expect(Government.find(content_id)).to be government
    end

    it "raises an error if there isn't a government for the id" do
      missing_content_id = SecureRandom.uuid
      expect { Government.find(missing_content_id) }
        .to raise_error(RuntimeError, "Government #{missing_content_id} not found")
    end
  end

  describe ".for_date" do
    let(:current_government) do
      build(:government,
            start_date: Date.parse("2018-12-01"),
            end_date: nil)
    end

    let(:past_government) do
      build(:government,
            start_date: Date.parse("2018-01-31"),
            end_date: Date.parse("2018-12-01"))
    end

    before do
      allow(Government).to receive(:all)
                       .and_return([current_government, past_government])
    end

    it "returns a government when there is one for the date" do
      expect(Government.for_date(Date.parse("2019-06-01"))).to eq current_government
    end

    it "returns nil when there isn't a government for the date" do
      expect(Government.for_date(Date.parse("2017-06-01"))).to be_nil
    end

    it "opts for the more recent government when there is a date conflict" do
      expect(Government.for_date(Date.parse("2018-12-01"))).to eq current_government
    end

    it "accepts a nil date" do
      expect(Government.for_date(nil)).to be_nil
    end
  end

  describe ".current" do
    let(:current_government) do
      build(:government,
            start_date: Date.parse("2018-12-01"),
            end_date: nil)
    end

    let(:past_government) do
      build(:government,
            start_date: Date.parse("2018-01-31"),
            end_date: Date.parse("2018-12-01"))
    end

    before do
      allow(Government).to receive(:all)
                       .and_return([current_government, past_government])
    end

    it "returns the current government" do
      expect(Government.current).to eq current_government
    end
  end

  describe ".past" do
    it "returns the past governments" do
      past = Government.past
      expect(past).not_to be_empty
      expect(past).to all be_a(Government)
      expect(past).not_to include(Government.current)
    end
  end

  describe "#covers?" do
    let(:government) do
      build(:government, start_date: start_date, end_date: end_date)
    end

    context "when there isn't an end date" do
      let(:start_date) { Date.parse("2019-11-18") }
      let(:end_date) { nil }

      it "returns false before the start date" do
        expect(government.covers?(Date.parse("2019-11-01"))).to be false
      end

      it "returns true on the start date" do
        expect(government.covers?(Date.parse("2019-11-18"))).to be true
      end

      it "returns true after the start date" do
        expect(government.covers?(Date.parse("2019-11-20"))).to be true
      end
    end

    context "when there is a start date and an end date" do
      let(:start_date) { Date.parse("2019-11-18") }
      let(:end_date) { Date.parse("2019-11-20") }

      it "returns false before the start date" do
        expect(government.covers?(Date.parse("2019-11-17"))).to be false
      end

      it "returns false after the end date" do
        expect(government.covers?(Date.parse("2019-11-21"))).to be false
      end

      it "returns true in between the dates" do
        expect(government.covers?(Date.parse("2019-11-19"))).to be true
      end

      it "returns true on the end date" do
        expect(government.covers?(Date.parse("2019-11-20"))).to be true
      end

      it "returns true with a time within the end date" do
        time = Time.zone.parse("2019-11-20 23:55")
        expect(government.covers?(time)).to be true
      end
    end
  end

  describe "#current?" do
    let(:government) { build(:government) }

    it "returns true when the government is the current one" do
      allow(Government).to receive(:current).and_return(government)
      expect(government.current?).to be true
    end

    it "returns false when the government is not the current one" do
      expect(government.current?).to be false
    end
  end

  describe "#publishing_api_payload" do
    it "returns the fields needed for presenting to Publishing API" do
      government = build(:government,
                         name: "Past Government",
                         slug: "past-government")

      expect(government.publishing_api_payload).to eq(
        "title" => "Past Government",
        "slug" => "past-government",
        "current" => false,
      )
    end
  end
end
