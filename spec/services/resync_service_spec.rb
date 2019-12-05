# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
      stub_default_publishing_api_path_reservation
    end

    context "when there is no live edition" do
      let(:document) { create(:document, :with_current_edition) }

      it "it does not publish the edition" do
        expect(PreviewService).to receive(:call).with(document.current_edition)
        expect(GdsApi.publishing_api_v2).not_to receive(:publish)
        ResyncService.call(document)
      end
    end

    context "when the current edition is live" do
      let(:document) { create(:document, :with_live_edition) }

      it "avoids synchronising the edition twice" do
        expect(PreviewService).to receive(:call).once
        ResyncService.call(document)
      end

      it "re-publishes the live edition" do
        expect(PreviewService)
          .to receive(:call)
          .with(
            document.current_edition,
            republish: true,
          )
          .and_call_original

        ResyncService.call(document)

        assert_publishing_api_publish(document.content_id)
      end

      it "publishes assets to the live stack" do
        expect(PublishAssetService).to receive(:call).once.
          with(document.live_edition, nil)
        ResyncService.call(document)
      end
    end

    context "when the live edition is withdrawn" do
      let(:edition) { create(:edition, :withdrawn) }
      let(:explanation) { "explanation" }

      before do
        stub_any_publishing_api_unpublish
        allow(PreviewAssetService).to receive(:call)
        allow(PublishAssetService).to receive(:call)
      end

      it "withdraws the edition" do
        allow(GovspeakDocument)
          .to receive(:new)
          .and_return(instance_double(GovspeakDocument, payload_html: explanation))

        withdraw_params = {
          "type" => "withdrawal",
          "explanation" => explanation,
          "locale" => edition.locale,
        }

        expect(GovspeakDocument)
          .to receive(:new)
          .with(edition.status.details, edition)

        ResyncService.call(edition.document)
        assert_publishing_api_unpublish(edition.content_id, withdraw_params, 1)
      end
    end

    context "when the live edition has been removed" do
      let(:explanation) { "explanation" }

      before do
        stub_any_publishing_api_unpublish
        allow(PreviewAssetService).to receive(:call)
        allow(PublishAssetService).to receive(:call)
      end

      context "when the live edition is removed with a redirect" do
        let(:removal) do
          build(
            :removal,
            redirect: true,
            alternative_path: "/foo/bar",
            explanatory_note: explanation,
          )
        end

        let(:edition) { create(:edition, :removed, removal: removal) }

        it "removes and redirects the edition" do
          remove_params = {
            "type" => "redirect",
            "explanation" => explanation,
            "alternative_path" => removal.alternative_path,
            "locale" => edition.locale,
          }

          ResyncService.call(edition.document)
          assert_publishing_api_unpublish(edition.content_id, remove_params, 1)
        end
      end

      context "when the live edition is removed without a redirect" do
        let(:edition) { create(:edition, :removed) }

        it "removes the edition" do
          remove_params = {
            "type" => "gone",
            "locale" => edition.locale,
          }

          ResyncService.call(edition.document)
          assert_publishing_api_unpublish(edition.content_id, remove_params, 1)
        end
      end
    end

    context "when there are both live and current editions" do
      let(:document) { create(:document, :with_current_and_live_editions, first_published_at: Time.current) }
      let(:government) { build(:government) }

      before do
        allow(Government).to receive(:all).and_return([government])
        allow(PoliticalEditionIdentifier)
          .to receive(:new)
          .and_return(instance_double(PoliticalEditionIdentifier, political?: true))
      end

      it "updates the system_political value associated with both editions" do
        expect { ResyncService.call(document) }
          .to change { document.live_edition.system_political }.to(true)
          .and change { document.current_edition.system_political }.to(true)
      end

      it "updates the government_id associated with with both editions" do
        expect { ResyncService.call(document) }
          .to change { document.live_edition.government_id }.to(government.content_id)
          .and change { document.current_edition.government_id }.to(government.content_id)
      end
    end

    it "reserves the path of the edition" do
      edition = create(:edition)
      reserve_path_params = {
        publishing_app: "content-publisher",
        override_existing: true,
      }

      request = stub_publishing_api_path_reservation(edition.base_path, reserve_path_params)
      ResyncService.call(edition.document)

      expect(request).to have_been_requested
    end

    def stub_publishing_api_path_reservation(base_path, params)
      endpoint = GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT
      url = endpoint + "/paths#{base_path}"

      stub_request(:put, url).with(body: params)
    end
  end
end
