RSpec.describe Government do
  describe "#==" do
    it "returns true when content_id and locale are equal" do
      government = build(:government, started_on: Time.zone.today)
      other = build(:government,
                    content_id: government.content_id,
                    locale: government.locale,
                    started_on: Time.zone.yesterday)

      expect(government).to eq(other)
    end

    it "returns false when content_id doesn't match" do
      government = build(:government, content_id: SecureRandom.uuid, locale: "en")
      other = build(:government, content_id: SecureRandom.uuid, locale: "en")
      expect(government).not_to eq(other)
    end

    it "returns false when locale doesn't match" do
      content_id = SecureRandom.uuid
      english = build(:government, content_id: content_id, locale: "en")
      french = build(:government, content_id: content_id, locale: "fr")
      expect(english).not_to eq(french)
    end
  end

  describe "#covers?" do
    let(:government) do
      build(:government, started_on: started_on, ended_on: ended_on)
    end

    context "when there isn't an end date" do
      let(:started_on) { Date.parse("2019-11-18") }
      let(:ended_on) { nil }

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
      let(:started_on) { Date.parse("2019-11-18") }
      let(:ended_on) { Date.parse("2019-11-20") }

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

  describe "#started_on" do
    it "returns a date" do
      expect(build(:government).started_on).to be_a(Date)
    end
  end

  describe "#ended_on" do
    it "returns a date when ended on is set" do
      government = build(:government, ended_on: Time.zone.yesterday)
      expect(government.ended_on).to be_a(Date)
    end

    it "returns nil when an end date isn't set" do
      government = build(:government, ended_on: nil)
      expect(government.ended_on).to be_nil
    end
  end

  describe "#current?" do
    it "returns true when the government is marked as the current one" do
      expect(build(:government, current: true).current?).to be true
    end

    it "returns false when the government is not the current one" do
      expect(build(:government, current: false).current?).to be false
    end
  end
end
