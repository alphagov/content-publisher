# frozen_string_literal: true

RSpec.describe GovspeakDocument::PayloadOptions do
  describe "#to_h" do
    it "returns the remote asset options for the image" do
      image_revision = build(:image_revision,
                             :on_asset_manager,
                             alt_text: "Some alt text",
                             caption: "An optional caption",
                             credit: "An optional credit",
                             filename: "filename.png")
      edition = build(:edition,
                      image_revisions: [image_revision])

      payload_options = GovspeakDocument::PayloadOptions.new("govspeak", edition)
      actual_image_options = payload_options.to_h[:images].first
      expect(actual_image_options[:alt_text]).to eq("Some alt text")
      expect(actual_image_options[:caption]).to eq("An optional caption")
      expect(actual_image_options[:credit]).to eq("An optional credit")
      expect(actual_image_options[:url]).to match("filename.png")
      expect(actual_image_options[:url]).to match("/media")
      expect(actual_image_options[:id]).to eq("filename.png")
    end
  end
end
