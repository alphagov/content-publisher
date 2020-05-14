RSpec.describe ContentRevision::ContentsValidator do
  describe "#validate_each" do
    let(:record) { build :content_revision }
    let(:attribute) { :contents }
    let(:validator) { described_class.new(attributes: [attribute]) }

    it "validates when the contents are valid" do
      contents = { body: "some text" }
      validator.validate_each(record, attribute, contents)
      expect(record).to be_valid
    end

    it "fails if a field is not recognised" do
      expect { validator.validate_each(record, attribute, { foo: "text" }) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Contents has unknown content field ‘foo’",
        )
    end

    it "fails if the body field is not a string" do
      expect { validator.validate_each(record, attribute, { body: nil }) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Contents has non-string ‘body’ field",
        )
    end
  end
end
