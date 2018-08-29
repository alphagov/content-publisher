# frozen_string_literal: true


RSpec.describe UpdateImageCropService do
  describe "#valid?" do
    context "when valid crop parameters are provided" do
      it "returns true" do
        service = UpdateImageCropService.new(
          build(:image), x: 10, y: 10, width: 3000, height: 2000
        )
        expect(service.valid?).to be(true)
      end
    end

    context "when invalid crop parameters are provided" do
      it "returns true" do
        service = UpdateImageCropService.new(
          build(:image), x: "string", y: 10, width: 1.5523
        )
        expect(service.valid?).to be(false)
      end
    end
  end

  describe "#errors" do
    it "it returns an ActiveModel::Errors instance" do
      service = UpdateImageCropService.new(build(:image), {})
      expect(service.errors).to be_a(ActiveModel::Errors)
    end

    context "when non integers are provided" do
      it "returns numericality errors" do
        service = UpdateImageCropService.new(
          build(:image), x: "a", y: 0.1232, width: nil, height: "b"
        )

        expect(service.errors.to_h).to match(
          a_hash_including(
            x: I18n.t("errors.messages.not_a_number"),
            y: I18n.t("errors.messages.not_an_integer"),
            width: I18n.t("errors.messages.not_a_number"),
            height: I18n.t("errors.messages.not_a_number"),
          ),
        )
      end
    end

    context "when incorrect integers are provided" do
      it "returns numericality errors" do
        service = UpdateImageCropService.new(
          build(:image), x: -100, y: -100, width: 300, height: 200
        )

        expect(service.errors.to_h).to match(
          a_hash_including(
            x: I18n.t("errors.messages.greater_than_or_equal_to", count: 0),
            y: I18n.t("errors.messages.greater_than_or_equal_to", count: 0),
            width: I18n.t("errors.messages.greater_than_or_equal_to", count: Image::WIDTH),
            height: I18n.t("errors.messages.greater_than_or_equal_to", count: Image::HEIGHT),
          ),
        )
      end
    end

    context "when an invalid aspect ratio is uploaded" do
      it "returns an aspect ratio error on base" do
        service = UpdateImageCropService.new(
          build(:image), x: 0, y: 0, width: 3000, height: 3000
        )
        expect(service.errors[:base]).to match(
          [I18n.t("validations.images.aspect_ratio", aspect_ratio: "3:2")],
        )
      end
    end
  end

  describe "update_image" do
    context "when the dimensions are valid" do
      it "updates the image object associated with the service" do
        image = create(:image)
        service = UpdateImageCropService.new(
          image, x: 100, y: 100, width: 3000, height: 2000
        )

        expect { service.update_image }
          .to change { image.crop_x }.to(100)
          .and change { image.crop_y }.to(100)
          .and change { image.crop_width }.to(3000)
          .and change { image.crop_height }.to(2000)
      end
    end

    context "when the dimensions are invalid" do
      it "raises an error" do
        image = create(:image)
        service = UpdateImageCropService.new(
          image, x: 100, y: 100, width: 200, height: 200
        )

        expect { service.update_image }
          .to raise_error(RuntimeError, "Invalid crop")
      end
    end
  end
end
