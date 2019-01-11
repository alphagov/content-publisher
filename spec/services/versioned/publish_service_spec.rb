# frozen_string_literal: true

RSpec.describe Versioned::PublishService do
  describe "#publish" do
    before do
      # stub all asset manager requests
      stub_request(:any, /\A#{Plek.current.find('asset-manager')}/)
    end

    context "when there is no live edition" do
      let(:edition) { create(:versioned_edition, :publishable) }
      let!(:publish_request) do
        stub_publishing_api_publish(edition.content_id,
                                    update_type: nil,
                                    locale: edition.locale)
      end

      it "publishes the current_edition" do
        Versioned::PublishService.new(edition.document)
                                 .publish(user: create(:user), with_review: true)
        edition.reload
        expect(publish_request).to have_been_requested
        expect(edition.live).to be(true)
        expect(edition.document.live_edition).to eq(edition)
        expect(edition).to be_published
      end

      it "can specify if edition is reviewed" do
        Versioned::PublishService.new(edition.document)
                                 .publish(user: create(:user), with_review: false)
        edition.reload
        expect(publish_request).to have_been_requested
        expect(edition).to be_published_but_needs_2i
      end
    end

    context "when there is a live edition" do
      it "supersedes the live edition" do
        document = create(:versioned_document, :with_current_and_live_editions)
        current_edition = document.current_edition
        live_edition = document.live_edition
        stub_publishing_api_publish(document.content_id,
                                    update_type: nil,
                                    locale: document.locale)

        Versioned::PublishService.new(document)
                                 .publish(user: create(:user), with_review: true)

        document.reload
        expect(document.live_edition).to eq(current_edition)
        expect(live_edition).to be_superseded
      end
    end

    context "when the current edition has a lead image" do
      let(:lead_image) { create(:versioned_image_revision, :on_asset_manager) }
      let!(:edition) do
        create(:versioned_edition,
               :publishable,
               lead_image_revision: lead_image)
      end

      before do
        stub_publishing_api_publish(edition.content_id,
                                    update_type: nil,
                                    locale: edition.locale)
      end

      it "makes the lead image variants live" do
        expect(lead_image.asset_manager_variants.map(&:state).uniq)
          .to eq(%w[draft])

        Versioned::PublishService.new(edition.document)
                                 .publish(user: create(:user), with_review: true)

        lead_image.reload
        expect(lead_image.asset_manager_variants.map(&:state).uniq)
          .to eq(%w[live])
      end
    end

    context "when the live edition has live images" do
      let(:old_lead_image) do
        create(:versioned_image_revision, :on_asset_manager, state: :live)
      end

      let(:other_image) do
        create(:versioned_image_revision, :on_asset_manager, state: :live)
      end

      let(:document) { create(:versioned_document) }

      let!(:live_edition) do
        create(:versioned_edition,
               :published,
               lead_image_revision: old_lead_image,
               image_revisions: [old_lead_image, other_image],
               current: false,
               document: document)
      end

      let!(:current_edition) do
        create(:versioned_edition,
               :publishable,
               lead_image_revision: other_image,
               document: document)
      end

      before do
        stub_publishing_api_publish(document.content_id,
                                    update_type: nil,
                                    locale: document.locale)
      end

      it "removes ones not used by the current edition" do
        Versioned::PublishService.new(document)
                                 .publish(user: create(:user), with_review: true)

        old_lead_image.reload
        expect(old_lead_image.asset_manager_variants.map(&:state).uniq)
          .to eq(%w[absent])
      end

      it "keeps images used by the current edition" do
        Versioned::PublishService.new(document)
                                 .publish(user: create(:user), with_review: true)

        other_image.reload
        expect(old_lead_image.asset_manager_variants.map(&:state).uniq)
          .to eq(%w[live])
      end
    end

    context "when the current edition has an updated version of the live editions lead image" do
      let(:old_lead_image) do
        create(:versioned_image_revision, :on_asset_manager, state: :live)
      end

      let(:new_lead_image) do
        create(:versioned_image_revision,
               :on_asset_manager,
               image: old_lead_image.image)
      end

      let(:document) { create(:versioned_document) }

      let!(:live_edition) do
        create(:versioned_edition,
               :published,
               lead_image_revision: old_lead_image,
               current: false,
               document: document)
      end

      let!(:current_edition) do
        create(:versioned_edition,
               :publishable,
               lead_image_revision: new_lead_image,
               document: document)
      end

      before do
        stub_publishing_api_publish(document.content_id,
                                    update_type: nil,
                                    locale: document.locale)
      end

      it "supersedes the old files" do
        Versioned::PublishService.new(document)
                                 .publish(user: create(:user), with_review: true)

        old_lead_image.reload
        expect(old_lead_image.asset_manager_variants.map(&:state).uniq)
          .to eq(%w[superseded])
      end
    end
  end
end
