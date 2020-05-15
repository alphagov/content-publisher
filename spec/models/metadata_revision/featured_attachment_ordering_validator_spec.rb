RSpec.describe MetadataRevision::FeaturedAttachmentOrderingValidator do
  describe "#validate_each" do
    let(:record) { build :metadata_revision }
    let(:attribute) { :featured_attachment_ordering }
    let(:validator) { described_class.new(attributes: [attribute]) }

    it "validates when the ordering is valid" do
      validator.validate_each(record, attribute, %w[FileAttachment1])
      expect(record).to be_valid
    end

    it "fails if an order item ID is malformed" do
      expect { validator.validate_each(record, attribute, ["FileAttachment1 "]) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Featured attachment ordering has an entry with a malformed ID",
        )
    end

    it "fails if an order item type is malformed" do
      expect { validator.validate_each(record, attribute, %w[InvalidType1]) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Featured attachment ordering has an entry with a malformed ID",
        )
    end

    it "fails if there is a duplicate entry" do
      expect { validator.validate_each(record, attribute, %w[FileAttachment1 FileAttachment1]) }
        .to raise_error(
          ActiveModel::StrictValidationFailed,
          "Featured attachment ordering has a duplicate entry",
        )
    end
  end
end
