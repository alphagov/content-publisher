# frozen_string_literal: true

RSpec.describe PublishService do
  before { stub_any_publishing_api_publish }

  describe "#publish" do
    context "when there is no live edition" do
      let(:edition) { create(:edition, :publishable) }

      it "publishes the current_edition" do
        publish_request = stub_publishing_api_publish(edition.content_id,
                                                      update_type: nil,
                                                      locale: edition.locale)
        PublishService.new(edition)
                      .publish(user: create(:user), with_review: true)

        expect(publish_request).to have_been_requested
        expect(edition.document.live_edition).to eq(edition)
        expect(edition).to be_published
        expect(edition).to be_live
      end

      it "can specify if edition is reviewed" do
        PublishService.new(edition)
                      .publish(user: create(:user), with_review: false)

        expect(edition).to be_published_but_needs_2i
      end
    end

    context "when there is a live edition" do
      it "supersedes the live edition" do
        document = create(:document, :with_current_and_live_editions)
        current_edition = document.current_edition
        live_edition = document.live_edition

        PublishService.new(current_edition)
                      .publish(user: create(:user), with_review: true)

        expect(document.live_edition).to eq(current_edition)
        expect(live_edition).to be_superseded
      end
    end

    it "calls the PublishAssetService" do
      document = create(:document, :with_current_and_live_editions)
      current_edition = document.current_edition

      expect_any_instance_of(PublishAssetService).to receive(:publish_assets)

      PublishService.new(current_edition)
        .publish(user: create(:user), with_review: true)
    end
  end

  context "when the edition is access limited" do
    it "removes the access limit" do
      edition = create(:edition, :access_limited)

      PublishService.new(edition)
                    .publish(user: create(:user), with_review: true)

      expect(edition.access_limit).to be_nil
    end
  end
end
