# frozen_string_literal: true

RSpec.describe Document do
  describe "#newly_created?" do
    it "returns false if there isn't a current edition" do
      document = create(:edition, current: false).document

      expect(document.newly_created?).to be false
    end

    it "returns false if the current edition isn't the first one" do
      document = create(:edition, current: true, number: 3).document

      expect(document.newly_created?).to be false
    end

    it "returns true if the timestamps are equal" do
      document = create(:edition, current: true, number: 1).document

      expect(document.newly_created?).to be true
    end
  end
end
