# frozen_string_literal: true

RSpec.describe Images::UpdateInteractor do
  def strong_params(**params)
    ActionController::Parameters.new(params)
  end

  describe ".call" do
    let(:user) { create(:user) }
    let(:image_revision) { create(:image_revision) }
    let(:edition) { create(:edition, image_revisions: [image_revision]) }
    let(:preview_service) { double(try_create_preview: nil) }
    let(:success_params) do
      {
        document: edition.document.to_param,
        image_id: image_revision.image_id,
        image_revision: { alt_text: "alt text" },
      }
    end

    before do
      allow(PreviewService)
        .to receive(:new).with(edition).and_return(preview_service)
    end

    context "when an image is updated" do
      it "creates a new revision" do
        expect { Images::UpdateInteractor.call(params: strong_params(success_params), user: user) }
          .to(change { edition.reload.revision })
        image_revision = edition.image_revisions.first
        alt_text = success_params[:image_revision][:alt_text]
        expect(image_revision.alt_text).to eq(alt_text)
      end

      it "creates a preview" do
        expect(preview_service).to receive(:try_create_preview)
        Images::UpdateInteractor.call(params: strong_params(success_params), user: user)
      end
    end

    context "when an image is updated without changing lead image" do
      it "creates a image_updated timeline entry" do
        expect(TimelineEntry)
          .to receive(:create_for_revision)
          .with(entry_type: :image_updated, edition: edition)
        Images::UpdateInteractor.call(params: strong_params(success_params), user: user)
      end
    end

    context "when a new lead image is selected" do
      let(:params) do
        strong_params(success_params.merge(lead_image: "on"))
      end

      it "sets the edition lead image" do
        expect { Images::UpdateInteractor.call(params: params, user: user) }
          .to change { edition.reload.lead_image_revision }
          .from(nil)
      end

      it "creates a lead image selected timeline entry" do
        expect(TimelineEntry)
          .to receive(:create_for_revision)
          .with(entry_type: :lead_image_selected, edition: edition)
        Images::UpdateInteractor.call(params: params, user: user)
      end
    end

    context "when a lead image is removed" do
      let(:edition) { create(:edition, lead_image_revision: image_revision) }
      let(:params) do
        strong_params(success_params.merge(lead_image: nil))
      end

      it "removes the edition lead image" do
        expect { Images::UpdateInteractor.call(params: params, user: user) }
          .to change { edition.reload.lead_image_revision }
          .to(nil)
      end

      it "creates a lead image removed timeline entry" do
        expect(TimelineEntry)
          .to receive(:create_for_revision)
          .with(entry_type: :lead_image_removed, edition: edition)
        Images::UpdateInteractor.call(params: params, user: user)
      end
    end

    context "when the image isn't changed" do
      let(:image_revision) { create(:image_revision, alt_text: "existing") }
      let(:params) do
        strong_params(success_params.merge(image_revision: { alt_text: "existing" }))
      end

      it "doesn't create a timeline entry" do
        expect { Images::UpdateInteractor.call(params: params, user: user) }
          .not_to change(TimelineEntry, :count)
      end

      it "doesn't update the editions revision" do
        expect { Images::UpdateInteractor.call(params: params, user: user) }
          .not_to(change { edition.reload.revision })
      end

      it "doesn't preview" do
        expect(preview_service).not_to receive(:try_create_preview)
        Images::UpdateInteractor.call(params: params, user: user)
      end
    end

    context "when there are issues" do
      it "fails with issues" do
        result = Images::UpdateInteractor.call(
          params: strong_params(
            document: edition.document.to_param,
            image_id: image_revision.image_id,
            image_revision: { alt_text: "" },
          ),
          user: user,
        )
        expect(result).to be_failure
        expect(result.issues.any?).to be(true)
      end
    end

    context "when the image does not exist" do
      let(:edition) { create(:edition) }

      it "raises an ActiveRecord::RecordNotFound error" do
        params = strong_params(
          document: edition.document.to_param,
          image_id: Image.maximum(:id).to_i + 1,
          image_revision: { caption: "Caption" },
        )

        expect { Images::UpdateInteractor.call(params: params, user: user) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
