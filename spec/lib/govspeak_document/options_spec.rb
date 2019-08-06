# frozen_string_literal: true

RSpec.describe GovspeakDocument::Options do
  let(:contacts_service) { instance_double(Contacts) }

  before do
    allow(Contacts).to receive(:new).and_return(contacts_service)
  end

  context "when an unknown contact is referenced" do
    before do
      allow(contacts_service).to receive(:by_content_id).and_return(nil)
    end

    it "returns empty contacts options" do
      content_id = SecureRandom.uuid
      govspeak = "[Contact:#{content_id}]"
      edition = create(:edition)
      options = GovspeakDocument::Options.new(govspeak, edition)
      actual_contacts_options = options.to_h[:contacts]
      expect(actual_contacts_options).to be_empty
    end
  end

  context "when a known contact that is referenced" do
    let(:content_id) { SecureRandom.uuid }

    before do
      allow(contacts_service).to receive(:by_content_id).with(content_id).and_return("Contact")
    end

    it "returns the contacts options" do
      govspeak = "[Contact:#{content_id}]"
      edition = create(:edition)
      options = GovspeakDocument::Options.new(govspeak, edition)
      actual_contacts_options = options.to_h[:contacts].first
      expect(actual_contacts_options).to eq("Contact")
    end
  end
end
