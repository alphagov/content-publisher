# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    it "updates the system_political value associated with the current edition" do
      document = create(:document, :with_current_edition)
      PoliticalEditionIdentifier.stub_chain(:new, :political?).and_return(true)

      expect(document.current_edition.system_political).to be false
      ResyncService.call(document)
      expect(document.current_edition.system_political).to be true
    end
  end
end
