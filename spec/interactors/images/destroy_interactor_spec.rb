# frozen_string_literal: true

RSpec.describe Images::DestroyInteractor do
  def strong_params(**params)
    ActionController::Parameters.new(params)
  end

  describe ".call" do
    let(:user) { create(:user) }
    let(:image_revision) { create(:image_revision, :on_asset_manager) }
    let(:edition) { create(:edition, image_revisions: [image_revision]) }
    let(:params) do
      strong_params(
        document: edition.document.to_param,
        image_id: image_revision.image_id,
      )
    end

    let(:preview_service) { double(try_create_preview: nil) }

    before do
      allow(PreviewService)
        .to receive(:new).with(edition).and_return(preview_service)
    end

    it "creates a revision without the image revision" do
      Images::DestroyInteractor.call(params: params, user: user)
      revision = edition.reload.revision
      expect(revision.image_revisions).not_to include(image_revision)
    end

    it "creates a timeline entry" do
      expect(TimelineEntry)
        .to receive(:create_for_revision)
        .with(entry_type: :image_deleted, edition: edition)
      Images::DestroyInteractor.call(params: params, user: user)
    end

    it "creates a preview" do
      expect(preview_service).to receive(:try_create_preview)
      Images::DestroyInteractor.call(params: params, user: user)
    end

    context "when the image does not exist" do
      let(:edition) { create(:edition) }

      it "raises an ActiveRecord::RecordNotFound error" do
        params = strong_params(
          document: edition.document.to_param,
          image_id: Image.maximum(:id).to_i + 1,
        )

        expect { Images::DestroyInteractor.call(params: params, user: user) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
