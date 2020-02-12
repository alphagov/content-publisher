class DocumentType
  include InitializeWithHash

  attr_reader :contents, :id, :managed_elsewhere, :publishing_metadata, :label,
              :path_prefix, :tags, :images, :topics

  def self.find(id)
    item = all.find { |document_type| document_type.id == id }
    item || (raise RuntimeError, "Document type #{id} not found")
  end

  def self.all
    @all ||= begin
      hashes = YAML.load_file(Rails.root.join("config/document_types.yml"))

      hashes.map do |hash|
        hash["contents"] = hash["contents"].to_a.map do |field_id|
          "DocumentType::#{field_id.camelize}Field".constantize.new
        end

        hash["tags"] = hash["tags"].to_a.map(&TagField.method(:new))
        hash["publishing_metadata"] = PublishingMetadata.new(hash["publishing_metadata"].to_h)
        hash["topics"] = true # this feature is only disabled in tests
        new(hash)
      end
    end
  end

  def self.clear
    @all = nil
  end

  class TagField
    include InitializeWithHash
    attr_reader :id, :type, :document_type, :hint
  end

  class PublishingMetadata
    include InitializeWithHash
    attr_reader :schema_name, :rendering_app
  end
end
