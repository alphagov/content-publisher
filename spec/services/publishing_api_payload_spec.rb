# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "transforms Govspeak before sending it to the publishing-api" do
      body_field_schema = build(:field_schema, type: "govspeak", id: "body")
      document_type_schema = build(:document_type_schema, contents: [body_field_schema])
      document = build(:document, document_type: document_type_schema.id, contents: { body: "Hey **buddy**!" })

      payload = PublishingApiPayload.new(document).payload

      expect(payload[:details]["body"]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end
end
