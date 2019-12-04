# frozen_string_literal: true

RSpec.describe ResyncService do
  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
      allow(PoliticalEditionIdentifier)
        .to receive(:new)
        .and_return(instance_double(PoliticalEditionIdentifier, political?: true))
    end

    context "when there is no live edition" do
      let(:document) { create(:document, :with_current_edition) }

      it "synchronises the current edition, but does not publish" do
        expect(PreviewService).to receive(:call).with(document.current_edition).and_call_original
        expect(GdsApi.publishing_api_v2).not_to receive(:publish)
        ResyncService.call(document)
        expect(document.current_edition.revision_synced).to be true
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

        ResyncService.call(document)

        assert_publishing_api_publish(document.content_id)
        expect(document.current_edition.revision_synced).to be true
      end

      it "publishes assets to the live stack" do
        expect(PublishAssetService).to receive(:call).once.
          with(document.live_edition, nil)
        ResyncService.call(document)
      end
    end

    context "when the live edition has been unpublished" do
      let(:document) { create(:document, :with_live_edition) }
      let(:explanation) { "explanation" }

      before do
        stub_any_publishing_api_unpublish
        allow(GovspeakDocument)
          .to receive(:new)
          .and_return(instance_double(GovspeakDocument, payload_html: explanation))
      end

      context "when the live edition is withdrawn" do
        before do
          document.current_edition.stub(:withdrawn?).and_return(true)
        end

        it "unpublishes the edition as withdrawn" do
          unpublish_params = {
            "type" => "withdrawal",
            "explanation" => explanation,
            "locale" => document.current_edition.locale,
          }

          ResyncService.call(document)
          assert_publishing_api_unpublish(document.content_id, unpublish_params, 1)
        end
      end

      context "when the live edition is unpublished with redirect" do
        let(:removal) do
          build(
            :removal,
            redirect: true,
            alternative_path: "/foo/bar",
            explanatory_note: explanation,
          )
        end

        before do
          document.current_edition.stub(:removed?).and_return(true)
          document.current_edition.status.stub(:details).and_return(removal)
        end

        it "unpublishes the edition as redirected" do
          unpublish_params = {
            "type" => "redirect",
            "explanation" => explanation,
            "alternative_path" => removal.alternative_path,
            "locale" => document.current_edition.locale,
          }

          ResyncService.call(document)
          assert_publishing_api_unpublish(document.content_id, unpublish_params, 1)
        end
      end

      context "when the live edition is unpublished without a redirect" do
        let(:removal) { build(:removal) }

        before do
          document.current_edition.stub(:removed?).and_return(true)
          document.current_edition.status.stub(:details).and_return(removal)
        end

        it "unpublishes the edition as redirected" do
          unpublish_params = {
            "type" => "gone",
            "locale" => document.current_edition.locale,
          }

          ResyncService.call(document)
          assert_publishing_api_unpublish(document.content_id, unpublish_params, 1)
        end
      end
    end

    context "when there are both live and current editions" do
      let(:document) { create(:document, :with_current_and_live_editions) }
      let(:government) { build(:government) }

      before do
        allow(Government).to receive(:all).and_return([government])
      end

      it "updates the system_political value associated with both editions" do
        expect { ResyncService.call(document) }
          .to change { document.live_edition.system_political }.to(true)
          .and change { document.current_edition.system_political }.to(true)
      end

      it "updates the government_id associated with the live edition" do
        expect(document.live_edition.government_id).to be nil
        ResyncService.call(document)
        expect(document.live_edition.government_id).to eq government.content_id
      end

      it "updates the government_id associated with the current edition" do
        expect(document.current_edition.government_id).to be nil
        ResyncService.call(document)
        expect(document.current_edition.government_id).to eq government.content_id
      end
    end
  end
end
