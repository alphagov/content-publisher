# frozen_string_literal: true

RSpec.describe Linkables do
  describe "#select_options" do
    it "returns a sorted array of linkables" do
      linkable1 = { "content_id" => SecureRandom.uuid, "internal_name" => "linkable 1" }
      linkable2 = { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable 2" }
      stub_publishing_api_has_linkables([linkable2, linkable1], document_type: "topical_event")

      options = Linkables.new("topical_event").select_options

      expect(options).to eq([[linkable1["internal_name"], linkable1["content_id"]],
                             [linkable2["internal_name"], linkable2["content_id"]]])
    end
  end

  describe "#by_content_id" do
    it "returns the linkable with the matching content_id" do
      linkable = { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable 1" }
      stub_publishing_api_has_linkables([linkable], document_type: "topical_event")

      service = Linkables.new("topical_event")
      expect(service.by_content_id(linkable["content_id"])).to eq(linkable)
      expect(service.by_content_id("something-else")).to be_nil
    end
  end
end
