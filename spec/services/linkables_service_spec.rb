# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LinkablesService do
  describe "#select_options" do
    it "returns an array of titles with content_ids" do
      linkables = [
        {
          "content_id" => "f5461d92-d36f-4077-81d2-1d5e5b57d585",
          "title" => "UK Pavilion at Astana Expo 2017",
          "publication_state" => "published",
          "base_path" => "/government/topical-events/uk-pavilion-at-astana-expo-2017",
          "internal_name" => "UK Pavilion at Astana Expo 2017 ",
        }
      ]
      publishing_api_has_linkables(linkables, document_type: "topical_event")

      service = LinkablesService.new("topical_event")
      expect(service.select_options).to match([
        ["UK Pavilion at Astana Expo 2017", "f5461d92-d36f-4077-81d2-1d5e5b57d585"],
      ])
    end
  end
end
