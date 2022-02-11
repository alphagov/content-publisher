class DocumentType
  include InitializeWithHash

  attr_reader :collections,
              :contents,
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
        hash["collections"] = hash["collections"].to_h.each_with_object({}) do |(key, value), memo|
          memo[key] = Collection.new(key, value)
        end

        hash["contents"] = hash["contents"].to_a.map { |field_id| create_field(field_id) }
        hash["tags"] = hash["tags"].to_a.map { |field_id| create_field(field_id) }

        hash["publishing_metadata"] = PublishingMetadata.new(hash["publishing_metadata"].to_h)
        hash["topics"] = true # this feature is only disabled in tests
        new(hash)
      end
    end
  end

  def self.clear
    @all = nil
  end

  def self.create_field(field_id)
    if field_id.is_a?(Hash)
      "DocumentType::#{field_id["type"].camelize}Field".constantize.new(field_id.except("type"))
    else
      "DocumentType::#{field_id.camelize}Field".constantize.new
    end
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

  class Collection
    attr_reader :id, :singular_name, :plural_name, :fields, :distinguishing_field

    def initialize(id, config)
      @id = id
      @singular_name = config.dig("name", "singular")
      @plural_name = config.dig("name", "plural")
      @fields = config["fields"].map { |field_id| DocumentType.create_field(field_id) }
      @distinguishing_field = config.fetch("distinguishing_field", fields.first.name)
    end

    def updater_params_for_new_item(edition, params)
      existing_collection = edition.contents[id].to_a.dup

      item = fields.each_with_object({ "id" => SecureRandom.uuid }) do |field, hash|
        hash.deep_merge!(field.collection_params(params))
      end

      { "contents" => edition.contents.dup.merge({ id => existing_collection << item }) }
    end

    def updater_params_for_removed_item(edition, item_id)
      collection = edition.contents[id]
                          .to_a
                          .reject { |item| item["id"] == item_id }

      { "contents" => edition.contents.dup.merge({ id => collection }) }
    end

    def updater_params_for_updated_item(edition, item_id, params)
      existing_collection = edition.contents[id].to_a.dup

      index = existing_collection.find_index { |item| item["id"] == item_id }

      existing_collection[index] = fields.each_with_object({ "id" => item_id }) do |field, hash|
        hash.deep_merge!(field.collection_params(params))
      end

      { "contents" => edition.contents.dup.merge({ id => existing_collection }) }
    end
  end
end
