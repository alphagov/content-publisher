# frozen_string_literal: true

RSpec.describe ContactsService do
  describe "#by_content_id" do
    context "when a contact is found" do
      it "returns the contact" do
        content_id = SecureRandom.uuid
        contact = {
          "content_id" => content_id,
          "locale" => "en",
          "title" => "Clark Kent",
          "schema_name" => "contact",
          "document_type" => "contact",
        }
        publishing_api_has_item(contact)

        expect(ContactsService.new.by_content_id(content_id)).to eq(contact)
      end
    end

    context "when a contact is not found" do
      it "returns nil" do
        content_id = SecureRandom.uuid
        publishing_api_does_not_have_item(content_id)
        expect(ContactsService.new.by_content_id(content_id)).to be_nil
      end
    end

    context "when the returned result is not a contact" do
      it "returns nil" do
        content_id = SecureRandom.uuid
        news = {
          content_id: content_id,
          locale: "en",
          title: "Breaking news",
          schema_name: "news_article",
          document_type: "news_story",
        }
        publishing_api_has_item(news)

        expect(ContactsService.new.by_content_id(content_id)).to be_nil
      end
    end
  end
end
