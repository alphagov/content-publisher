# frozen_string_literal: true

RSpec.describe Versioned::DeleteDraftService do
  let(:user) { create :user }

  describe "#delete" do
    it "raises an exception if the current edition is live" do
      document = create :versioned_document, :with_live_edition

      expect { Versioned::DeleteDraftService.new(document, user).delete }
        .to raise_error "Trying to delete a live document"
    end

    it "attempts to delete the document preview" do
      document = create :versioned_document, :with_current_edition
      request = stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(request).to have_been_requested
    end

    # it "attempts to delete the document's assets" do
    #   document = create :document
    #   image = create :image, :in_preview, document: document
    #   stub_publishing_api_discard_draft(document.content_id)
    #   asset_manager_delete_asset(image.asset_manager_id)
    #   Versioned::DeleteDraftService.new(document).delete
    #   expect(Image.count).to be_zero
    # end

    it "sets the current edition of the document to nil if there is no live edition" do
      document = create :versioned_document, :with_current_edition
      stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to be_nil
    end

    it "sets the current edition of the document to current_edition if there is a live edition" do
      document = create :versioned_document, :with_current_and_live_editions
      live_edition = document.live_edition
      stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to eq(live_edition)
    end

    it "sets the status of the edition of the document to be discarded" do
      document = create :versioned_document, :with_current_edition
      edition = document.current_edition
      stub_publishing_api_discard_draft(document.content_id)
      Versioned::DeleteDraftService.new(document, user).delete
      expect(edition.status).to be_discarded
    end

    it "copes if the document preview does not exist" do
      document = create :versioned_document, :with_current_edition
      stub_any_publishing_api_call_to_return_not_found
      Versioned::DeleteDraftService.new(document, user).delete
      expect(document.reload.current_edition).to be_nil
    end

    # it "copes if an asset is not in Asset Manager" do
    #   document = create :document
    #   create :image, document: document
    #   stub_publishing_api_discard_draft(document.content_id)
    #   Versioned::DeleteDraftService.new(document).delete
    #   expect(Image.count).to be_zero
    #   expect(Document.count).to be_zero
    # end
    #
    # it "copes if an asset preview does not exist" do
    #   document = create :document
    #   image = create :image, :in_preview, document: document
    #   asset_manager_does_not_have_an_asset(image.asset_manager_id)
    #   stub_publishing_api_discard_draft(document.content_id)
    #   Versioned::DeleteDraftService.new(document).delete
    #   expect(Image.count).to be_zero
    #   expect(Document.count).to be_zero
    # end

    it "raises an error when the Pubishing API is down" do
      document = create :versioned_document, :with_current_edition
      publishing_api_isnt_available
      expect { Versioned::DeleteDraftService.new(document, user).delete }.to raise_error GdsApi::BaseError
    end

    # it "raises an error when Asset Manager is down" do
    #   document = create :document
    #   image = create :image, :in_preview, document: document
    #   asset_manager_delete_asset_failure(image.asset_manager_id)
    #   expect { Versioned::DeleteDraftService.new(document).delete }.to raise_error GdsApi::BaseError
    #   expect(document.publication_state).to eq "error_deleting_draft"
    # end
  end
end
