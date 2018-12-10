# frozen_string_literal: true

RSpec.describe ImageCentreCropper do
  describe "#dimensions" do
    context "when aspect ratios match" do
      it "doesn't suggest any cropping" do
        cropper = ImageCentreCropper.new(500, 250, 2.0)
        expect(cropper.dimensions)
          .to eq(x: 0, y: 0, width: 500, height: 250)
      end
    end

    context "when an image that is too wide is uploaded" do
      it "suggests reducing the width with a x offset" do
        cropper = ImageCentreCropper.new(500, 100, 16.to_f / 9)
        expect(cropper.dimensions)
          .to eq(x: 161, y: 0, width: 178, height: 100)
      end
    end

    context "when an image that is too tall is uploaded" do
      it "suggests reducing the height with a y offset" do
        cropper = ImageCentreCropper.new(500, 600, 4.to_f / 3)
        expect(cropper.dimensions)
          .to eq(x: 0, y: 112, width: 500, height: 375)
      end
    end
  end
end
