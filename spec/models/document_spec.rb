# frozen_string_literal: true

RSpec.describe Document do
  describe "PUBLICATION_STATES" do
    it "has correct translations for each state" do
      Document::PUBLICATION_STATES.each do |state|
        I18n.t!("publication_states.#{state}.name")
        I18n.t!("publication_states.#{state}.description")
      end
    end

    describe "#last_edited_by" do
      it "returns the user who last edited a document" do
        user1 = create(:user)
        user2 = create(:user)
        document = create(:document)
        create(:timeline_entry, entry_type: "updated_content", document: document, user: user1)
        create(:timeline_entry, entry_type: "updated_tags", document: document, user: user2)
        create(:timeline_entry, entry_type: "submitted", document: document, user: user1)

        expect(document.last_edited_by).to eq(user2)
      end

      it "returns nil if there are no edit-related timeline entries associated with a document" do
        document = create(:document)
        create(:timeline_entry, entry_type: "submitted", document: document)

        expect(document.last_edited_by).to be nil
      end
    end
  end
end
