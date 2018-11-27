# frozen_string_literal: true

RSpec.describe DeleteDraftService do
  describe "#delete" do
    it "raises an exception if the document is live" do
      document = create :document, :published

      expect { DeleteDraftService.new(document).delete }
        .to raise_error "Trying to delete a live document"
    end

    it "attempts to delete the document preview" do
      document = create :document, :in_preview
      request = stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document).delete
      expect(request).to have_been_requested
    end

    it "attempts to delete the document's assets" do
      document = create :document
      image = create :image, :in_preview, document: document
      stub_publishing_api_discard_draft(document.content_id)
      asset_manager_delete_asset(image.asset_manager_id)
      DeleteDraftService.new(document).delete
      expect(Image.count).to be_zero
    end

    it "destroys the document representing the draft" do
      document = create :document
      stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document).delete
      expect(Document.count).to be_zero
    end

    it "copes if the document preview does not exist" do
      document = create :document
      stub_any_publishing_api_call_to_return_not_found
      DeleteDraftService.new(document).delete
      expect(Document.count).to be_zero
    end

    it "copes if an asset is not in Asset Manager" do
      document = create :document
      create :image, document: document
      stub_publishing_api_discard_draft(document.content_id)
      DeleteDraftService.new(document).delete
      expect(Image.count).to be_zero
      expect(Document.count).to be_zero
    end

    it "copes if an asset preview does not exist" do
      document = create :document
      image = create :image, :in_preview, document: document

      # TODO: Move this into gds-api-adapters
      ASSET_MANAGER_ENDPOINT = Plek.current.find("asset-manager")
      asset_id = image.asset_manager_id
      stub_request(:delete, "#{ASSET_MANAGER_ENDPOINT}/assets/#{asset_id}").to_return(status: 404)
      stub_publishing_api_discard_draft(document.content_id)

      DeleteDraftService.new(document).delete
      expect(Image.count).to be_zero
      expect(Document.count).to be_zero
    end

    it "raises an error when the Pubishing API is down" do
      document = create :document
      publishing_api_isnt_available
      expect { DeleteDraftService.new(document).delete }.to raise_error GdsApi::BaseError
      expect(document.publication_state).to eq "error_deleting_draft"
    end

    it "raises an error when Asset Manager is down" do
      document = create :document
      image = create :image, :in_preview, document: document
      asset_manager_delete_asset_failure(image.asset_manager_id)
      expect { DeleteDraftService.new(document).delete }.to raise_error GdsApi::BaseError
      expect(document.publication_state).to eq "error_deleting_draft"
    end
  end
end
