# frozen_string_literal: true

require "spec_helper"

RSpec.describe DocumentPublishingService do
  describe ".generate_base_path" do
    it "converts a title into a slug" do
      service = DocumentPublishingService.new
      @document = create :document, :press_release
      expect(service.generate_base_path(@document, "A title")).to eq("/news/a-title")
    end
  end
end
