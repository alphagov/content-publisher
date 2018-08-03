# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "transforms Govspeak before sending it to the publishing-api" do
      document = build(:document, :with_body_in_schema, contents: { body: "Hey **buddy**!" })

      payload = PublishingApiPayload.new(document).payload

      expect(payload[:details]["body"]).to eql("<p>Hey <strong>buddy</strong>!</p>\n")
    end
  end
end
