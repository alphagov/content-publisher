# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LinkablesService do
  describe "#select_options" do
    it "returns an array of titles with content_ids" do
      linkable = { "content_id" => SecureRandom.uuid, "title" => "Linkable 1" }
      publishing_api_has_linkables([linkable], document_type: "topical_event")
      service = LinkablesService.new("topical_event")
      expect(service.select_options).to eq([[linkable["title"], linkable["content_id"]]])
    end
  end

  describe "#by_content_id" do
    it "returns the linkable with the matching content_id" do
      linkable = { "content_id" => SecureRandom.uuid, "title" => "Linkable 1" }
      publishing_api_has_linkables([linkable], document_type: "topical_event")
      service = LinkablesService.new("topical_event")
      expect(service.by_content_id(linkable["content_id"])).to eq linkable
      expect(service.by_content_id("something-else")).to be_nil
    end
  end
end
