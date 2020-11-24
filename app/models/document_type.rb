class DocumentType
  include InitializeWithHash

  attr_reader :contents,
              :id,
              :publishing_metadata,
              :label,
              :path_prefix,
              :tags,
              :topics

  def self.find(id)
    item = all.find { |document_type| document_type.id == id }
    item || (raise "Document type #{id} not found")
  end

  def self.all
    @all ||= begin
      hashes = YAML.load_file(Rails.root.join("config/document_types.yml"))["document_types"]

      hashes.map do |hash|
        hash["contents"] = hash["contents"].to_a.map do |field_id|
          if field_id.is_a?(Hash)
            "DocumentType::#{field_id["type"].camelize}Field".constantize.new(field_id.except("type"))
          else
            "DocumentType::#{field_id.camelize}Field".constantize.new
          end
        end
        hash["tags"] = hash["tags"].to_a.map do |field_id|
          "DocumentType::#{field_id.camelize}Field".constantize.new
        end

        hash["publishing_metadata"] = PublishingMetadata.new(hash["publishing_metadata"].to_h)
        hash["topics"] = true # this feature is only disabled in tests
        new(hash)
      end
    end
  end

  def self.clear
    @all = nil
  end

  def lead_image?
    @lead_image
  end

  def pre_release?
    @pre_release
  end

  def attachments
    ActiveSupport::StringInquirer.new(@attachments)
  end

  class PublishingMetadata
    include InitializeWithHash
    attr_reader :schema_name, :rendering_app
  end
end
