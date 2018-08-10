# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "transforms Govspeak before sending it to the publishing-api" do
      body_field = { id: "body", label: "Body", type: "govspeak" }
      document_type_schema = build(:document_type_schema, contents: [body_field])
      document = build(:document, document_type: document_type_schema.id, contents: { body: "Hey **buddy**!" })

      payload = PublishingApiPayload.new(document).payload

      expect(payload[:details]["body"]).to eql("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end
end
