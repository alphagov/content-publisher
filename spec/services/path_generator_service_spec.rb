# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PathGeneratorService do
  describe '.path' do
    it "converts a title into a base path when there is no duplicate" do
      service = PathGeneratorService.new
      publishing_api_has_lookups("/news/a-title": nil)
      @document = create :document, :press_release
      expect(service.path(@document, "A title")).to eq("/news/a-title")
    end

    it "raises a 'Duplicate path error' when a generated base path exists in Publishing API" do
      service = PathGeneratorService.new
      publishing_api_has_lookups("/news/a-title": "a-content-id")
      @document = create :document, :press_release
      expect { service.path(@document, "A title") }.to raise_error(RuntimeError, "Duplicate path error")
    end
  end
end
