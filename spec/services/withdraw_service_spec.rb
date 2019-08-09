# frozen_string_literal: true

RSpec.describe WithdrawService do
  include ActiveSupport::Testing::TimeHelpers

  describe "#call" do
    let(:edition) { create(:edition, :published) }
    let(:user) { create(:user) }
    let(:public_explanation) { "The document is [out of date](https://www.gov.uk)" }

    before { stub_any_publishing_api_unpublish }

    it "converts the public explanation Govspeak to HTML before sending to Publishing API" do
      converted_public_explanation = GovspeakDocument.new(public_explanation, edition).payload_html
      request = stub_publishing_api_unpublish(edition.content_id,
                                              body: { type: "withdrawal",
                                                      explanation: converted_public_explanation,
                                                      locale: edition.locale })
      WithdrawService.call(edition, public_explanation, user)

      expect(request).to have_been_requested
    end


    it "updates the edition status to withdrawn" do
      travel_to(Time.current) do
        WithdrawService.call(edition, public_explanation, user)
        edition.reload
        withdrawal = edition.status.details

        expect(edition.status).to be_withdrawn
        expect(withdrawal.public_explanation).to eq(public_explanation)
        expect(withdrawal.withdrawn_at).to eq(Time.current)
      end
    end

    it "saves the published_status to the withdrawal record" do
      previous_published_status = edition.status

      WithdrawService.call(edition, public_explanation, user)
      edition.reload

      withdrawal = edition.status.details

      expect(withdrawal.published_status).to eq(previous_published_status)
    end

    it "saves the correct published_status when the document is already withdrawn" do
      withdrawn_edition = create(:edition, :withdrawn)
      previous_withdrawal = withdrawn_edition.status.details

      WithdrawService.call(withdrawn_edition, public_explanation, user)

      withdrawal = withdrawn_edition.status.details

      expect(withdrawal.published_status).to eq(previous_withdrawal.published_status)
    end

    context "when the given edition is a draft" do
      it "raises an error" do
        draft_edition = create(:edition)
        expect { WithdrawService.call(draft_edition, public_explanation, user) }
          .to raise_error "attempted to withdraw an edition other than the live edition"
      end
    end

    context "when there is a live and a draft edition" do
      it "raises an error" do
        draft_edition = create(:edition)
        live_edition = create(:edition,
                              :published,
                              current: false,
                              document: draft_edition.document)

        expect { WithdrawService.call(live_edition, public_explanation, user) }
          .to raise_error "Publishing API does not support unpublishing while there is a draft"
      end
    end

    context "when an edition has assets" do
      it "does not delete assets for withdrawn editions" do
        image_revision = create(:image_revision, :on_asset_manager)
        edition = create(:edition, :published, lead_image_revision: image_revision)
        delete_request = stub_asset_manager_deletes_any_asset
        WithdrawService.call(edition, public_explanation, user)
        expect(delete_request).not_to have_been_requested
      end
    end

    context "when an edition is already withdrawn and public_explanation differs" do
      it "updates public_explanation" do
        withdrawn_edition = create(:edition, :withdrawn)
        expect { WithdrawService.call(withdrawn_edition, public_explanation, user) }
          .to change { withdrawn_edition.reload.status.details.public_explanation }
          .to(public_explanation)
      end

      it "maintains the withdrawn timestamp" do
        withdrawn_at = 10.days.ago.midnight
        withdrawal = build(:withdrawal, withdrawn_at: withdrawn_at)
        withdrawn_edition = create(:edition, :withdrawn, withdrawal: withdrawal)

        expect { WithdrawService.call(withdrawn_edition, public_explanation, user) }
          .not_to change { withdrawn_edition.reload.status.details.withdrawn_at }
          .from(withdrawn_at)
      end
    end
  end
end
