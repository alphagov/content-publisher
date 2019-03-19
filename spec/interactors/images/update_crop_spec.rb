# frozen_string_literal: true

RSpec.describe Images::UpdateCrop do
  def strong_params(**params)
    ActionController::Parameters.new(params)
  end

  describe ".call" do
    let(:user) { create(:user) }
    let(:preview_service) { double(try_create_preview: nil) }
    let(:image_revision) { create(:image_revision) }
    let(:edition) { create(:edition, image_revisions: [image_revision]) }

    before do
      allow(PreviewService)
        .to receive(:new).with(edition).and_return(preview_service)
    end

    context "when the crop has changed" do
      let(:params) do
        strong_params(
          document: edition.document.to_param,
          image_id: image_revision.image_id,
          crop_x: image_revision.crop_x + 10,
          crop_y: image_revision.crop_y + 10,
          crop_width: image_revision.crop_width,
        )
      end

      it "creates a new revision" do
        expect { Images::UpdateCrop.call(params: params, user: user) }
          .to(change { edition.reload.revision })
      end

      it "creates a timeline entry" do
        expect(TimelineEntry)
          .to receive(:create_for_revision)
          .with(entry_type: :image_updated, edition: edition)
        Images::UpdateCrop.call(params: params, user: user)
      end

      it "creates a preview" do
        expect(preview_service).to receive(:try_create_preview)
        Images::UpdateCrop.call(params: params, user: user)
      end
    end

    context "when the crop hasn't changed" do
      let(:params) do
        strong_params(
          document: edition.document.to_param,
          image_id: image_revision.image_id,
          crop_x: image_revision.crop_x,
          crop_y: image_revision.crop_y,
          crop_width: image_revision.crop_width,
        )
      end

      it "doesn't create a new revision" do
        expect { Images::UpdateCrop.call(params: params, user: user) }
          .not_to(change { edition.reload.revision })
      end

      it "doesn't create a timeline entry" do
        expect { Images::UpdateCrop.call(params: params, user: user) }
          .not_to change(TimelineEntry, :count)
      end

      it "creates a preview" do
        expect(preview_service).not_to receive(:try_create_preview)
        Images::UpdateCrop.call(params: params, user: user)
      end
    end

    context "when the image does not exist" do
      it "raises an ActiveRecord::RecordNotFound error" do
        params = strong_params(
          document: edition.document.to_param,
          image_id: Image.maximum(:id).to_i + 1,
        )

        expect { Images::UpdateCrop.call(params: params, user: user) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
