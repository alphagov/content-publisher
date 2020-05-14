RSpec.describe TagsRevision::TagsValidator do
  describe "#validate_each" do
    let(:record) { build :metadata_revision }
    let(:attribute) { :tags }
    let(:validator) { described_class.new(attributes: [attribute]) }

    it "validates when the tags are valid" do
      tags = { organisations: [SecureRandom.uuid] }
      validator.validate_each(record, attribute, tags)
      expect(record).to be_valid
    end

    it "fails if a field is not recognised" do
      expect { validator.validate_each(record, attribute, { foo: [] }) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Tags has unknown tag field ‘foo’",
        )
    end

    it "fails if a tag list is not an array" do
      expect { validator.validate_each(record, attribute, { organisations: "an-id" }) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Tags has non-array field ‘organisations’",
        )
    end

    it "fails if a tag is not in UUID format" do
      expect { validator.validate_each(record, attribute, { organisations: %w[an-id] }) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Tags has an invalid tag ID ‘an-id’",
        )
    end

    it "fails if a tag is nil" do
      expect { validator.validate_each(record, attribute, { organisations: [nil] }) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Tags has an invalid tag ID ‘’",
        )
    end
  end
end
