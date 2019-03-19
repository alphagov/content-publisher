# frozen_string_literal: true

RSpec.describe Images::Create do
  def strong_params(**params)
    ActionController::Parameters.new(params)
  end

  describe ".call" do
    let(:edition) { create(:edition) }
    let(:user) { create(:user) }

    context "when an image upload has issues" do
      it "fails with issues" do
        result = Images::Create.call(
          params: strong_params(
            document: edition.document.to_param,
            image: nil,
          ),
          user: user,
        )
        expect(result).to be_failure
        expect(result.issues.any?).to be(true)
      end
    end

    context "when an image upload doesn't have issues" do
      let(:params) do
        strong_params(
          document: edition.document.to_param,
          image: fixture_file_upload("files/960x640.jpg", "image/jpeg"),
        )
      end

      it "uploads an image" do
        expect { Images::Create.call(params: params, user: user) }
          .to change { Image.count }
          .by(1)
      end

      it "updates the edition revision" do
        expect { Images::Create.call(params: params, user: user) }
          .to(change { edition.reload.revision })
      end
    end
  end
end
