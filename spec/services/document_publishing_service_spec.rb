require "spec_helper"

RSpec.describe DocumentPublishingService do
  describe ".generate_base_path" do
    it "converts a title into a slug" do
      service = DocumentPublishingService.new
      expect(service.generate_base_path("A title")).to eq("/news/a-title")
    end
  end
end
