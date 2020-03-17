class MetadataRevision::FeaturedAttachmentOrderingValidator < ActiveModel::EachValidator
  ORDER_ITEM_REGEX = /\AFileAttachment\d+\Z/.freeze

  def validate_each(record, attribute, value)
    value.each do |order_item|
      unless order_item.match?(ORDER_ITEM_REGEX)
        record.errors.add(attribute, "has an entry with a malformed ID", strict: true)
      end
    end

    unless value.uniq == value
      record.errors.add(attribute, "has a duplicate entry", strict: true)
    end
  end
end
