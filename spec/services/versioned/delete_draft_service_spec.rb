# frozen_string_literal: true

RSpec.describe Versioned::DeleteDraftService do
  let(:user) { create :user }

  describe "#delete" do
    it "raises an exception if there is not a current edition" do
      document = create :versioned_document

      expect { Versioned::DeleteDraftService.new(document, user).delete }
        .to raise_error "Trying to delete a document without a current edition"
    end

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

    it "attempts to delete the assets from asset manager" do
      image_revision = create :versioned_image_revision, :in_preview
      edition = create :versioned_edition, lead_image_revision: image_revision

      stub_publishing_api_discard_draft(edition.content_id)
      requests = image_revision.asset_manager_variants.map do |variant|
        asset_manager_delete_asset(variant.asset_manager_id)
      end
      Versioned::DeleteDraftService.new(edition.document, user).delete
      requests.each { |req| expect(req).to have_been_requested }

      image_revision.reload.asset_manager_variants.each do |variant|
        expect(variant).to be_absent
      end
    end

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

    it "copes if an asset is not in Asset Manager" do
      image_revision = create :versioned_image_revision
      edition = create :versioned_edition, lead_image_revision: image_revision

      stub_publishing_api_discard_draft(edition.content_id)
      Versioned::DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded

      image_revision.reload.asset_manager_variants.each do |variant|
        expect(variant).to be_absent
      end
    end

    it "copes if an asset is not in Asset Manager" do
      image_revision = create :versioned_image_revision, :in_preview
      edition = create :versioned_edition, lead_image_revision: image_revision

      image_revision.asset_manager_variants.map do |variant|
        asset_manager_does_not_have_an_asset(variant.asset_manager_id)
      end

      stub_publishing_api_discard_draft(edition.content_id)
      Versioned::DeleteDraftService.new(edition.document, user).delete

      expect(edition.reload.status).to be_discarded
    end

    it "raises an error when the Pubishing API is down" do
      document = create :versioned_document, :with_current_edition
      publishing_api_isnt_available
      expect { Versioned::DeleteDraftService.new(document, user).delete }.to raise_error GdsApi::BaseError
    end

    it "raises an error when Asset Manager is down" do
      image_revision = create :versioned_image_revision, :in_preview
      edition = create :versioned_edition, lead_image_revision: image_revision

      image_revision.asset_manager_variants.map do |variant|
        asset_manager_delete_asset_failure(variant.asset_manager_id)
      end

      expect { Versioned::DeleteDraftService.new(edition.document, user).delete }
        .to raise_error(GdsApi::BaseError)
      expect(edition.reload.draft_failure?).to be true
    end
  end
end
