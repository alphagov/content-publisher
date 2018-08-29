# frozen_string_literal: true

RSpec.describe ImageAspectRatioValidator do
  subject(:instance) do
    anon_class = Class.new do
      include ActiveModel::Validations
      attr_accessor :width, :height
      validates_with ImageAspectRatioValidator
    end
    anon_class.new
  end

  it "is valid for a 3:2 aspect ratio" do
    instance.width = 3000
    instance.height = 2000
    expect(instance).to be_valid
  end

  it "is valid when rounding makes the aspect ratio slightly off" do
    # 664 wide at 3:2 equates to 442.666666
    instance.width = 664
    instance.height = 443
    expect(instance).to be_valid

    instance.width = 664
    instance.height = 442
    expect(instance).to be_valid

    # 443 wide at 3:2 equates to 664.5
    instance.height = 443
    instance.width = 664
    expect(instance).to be_valid

    instance.height = 443
    instance.width = 665
    expect(instance).to be_valid
  end

  it "is valid when the input isn't appropriate" do
    instance.width = 1.12321312
    instance.height = "a string"
    expect(instance).to be_valid
  end

  it "is invalid for an incorrect aspect ratio" do
    instance.width = 900
    instance.height = 100
    expect(instance).to be_invalid

    expect(instance.errors[:base]).to match(
      [I18n.t("validations.images.aspect_ratio", aspect_ratio: "3:2")],
    )
  end
end
