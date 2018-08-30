# frozen_string_literal: true

RSpec.describe Image do
  describe "validations" do
    it "is valid for the default factory" do
      expect(build(:image)).to be_valid
    end

    it "requires width to be an integer greater than or equal to 960" do
      expect(build(:image, width: "a")).to be_invalid
      expect(build(:image, width: -1)).to be_invalid
      expect(build(:image, width: 1000)).to be_valid
    end

    it "requires height to be an integer greater than or equal to 640" do
      expect(build(:image, height: "a")).to be_invalid
      expect(build(:image, height: -1)).to be_invalid
      expect(build(:image, height: 700)).to be_valid
    end

    it "requires crop_x to be an integer greater than or equal to 0" do
      expect(build(:image, crop_x: "a")).to be_invalid
      expect(build(:image, crop_x: -1)).to be_invalid
      expect(build(:image, crop_x: 10)).to be_valid
    end

    it "requires crop_y to be an integer greater than or equal to 0" do
      expect(build(:image, crop_y: "a")).to be_invalid
      expect(build(:image, crop_y: -1)).to be_invalid
      expect(build(:image, crop_y: 10)).to be_valid
    end

    it "requires crop_width to be an integer" do
      expect(build(:image, crop_width: "a")).to be_invalid
      expect(build(:image, crop_width: -1)).to be_invalid
    end

    it "requires crop_height to be an integer" do
      expect(build(:image, crop_height: "a")).to be_invalid
      expect(build(:image, crop_height: -1)).to be_invalid
    end

    it "requires crop_width and crop_width to be atleast 960x640px and 3:2 aspect ratio" do
      expect(build(:image, crop_width: 3000, crop_height: 1000)).to be_invalid
      expect(build(:image, crop_width: 3000, crop_height: 2000)).to be_valid
      expect(build(:image, crop_width: 300, crop_height: 200)).to be_invalid
    end
  end
end
