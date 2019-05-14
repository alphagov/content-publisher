# frozen_string_literal: true

RSpec.describe PreviewAuthBypassService do
  let(:document) do
    create :document, content_id: "1c24199f-1f98-426a-bea7-3f5ccc32e44d"
  end

  describe "#auth_bypass_id" do
    it "returns a hash of the content_id" do
      service = PreviewAuthBypassService.new(document)
      expect(service.auth_bypass_id).to eq "34323335-3863-4766-b866-636631376231"
    end
  end

  describe "#preview_token" do
    it "returns a hash of the auth_bypass_id" do
      service = PreviewAuthBypassService.new(document)
      expect(service.preview_token).to eq "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzNDMyMzMzNS0zODYzLTQ3NjYtYjg2Ni02MzY2MzEzNzYyMzEifQ.cPR22fZ8l584nEi-q2WHUDFxtqWDSg3BOoCVjcDALdw"
    end
  end
end
