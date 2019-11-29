# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
      PoliticalEditionIdentifier.stub_chain(:new, :political?).and_return(true)
    end

    it "updates the system_political value associated with the current edition" do
      document = create(:document, :with_current_edition)
      expect(document.current_edition.system_political).to be false
      ResyncService.call(document)
      expect(document.current_edition.system_political).to be true
    end

    it "updates the government_id associated with the live edition" do
      document = create(:document, :with_live_edition)
      expect(document.live_edition.government_id).to be nil
      ResyncService.call(document)
      expect(document.live_edition.government_id).to eq "d4fbc1b9-d47d-4386-af04-ac909f868f92"
    end
  end
end
