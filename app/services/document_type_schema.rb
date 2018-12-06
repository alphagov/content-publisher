# frozen_string_literal: true

class DocumentTypeSchema
  attr_reader :contents, :id, :label, :managed_elsewhere, :publishing_metadata,
    :path_prefix, :tags, :guidance_govspeak, :description, :hint, :lead_image, :topics, :check_path_conflict

  def initialize(params = {})
    @id = params["id"]
    @label = params["label"]
    @managed_elsewhere = params["managed_elsewhere"]
    @contents = params["contents"].to_a.map(&Field.method(:new))
    @publishing_metadata = PublishingMetadata.new(params["publishing_metadata"])
    @path_prefix = params["path_prefix"]
    @tags = params["tags"].to_a.map(&Tag.method(:new))
    @guidance = params["guidance"].to_a.map(&Guidance.method(:new))
    @description = params["description"]
    @hint = params["hint"]
    @lead_image = params["lead_image"]
    @topics = params["topics"]
    @check_path_conflict = params["check_path_conflict"]
  end

  def self.find(document_type_id)
    item = all.find { |schema| schema.id == document_type_id }
    item || (raise RuntimeError, "Document type #{document_type_id} not found")
  end

  def self.all
    @all ||= begin
      types = YAML.load_file("app/formats/document_types.yml")
      types.map { |data| DocumentTypeSchema.new(data) }
    end
  end

  def self.add_schema(params)
    schema = new(params)
    all << schema
    schema
  end

  def managed_elsewhere_url
    Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
  end

  def guidance_for(id)
    @guidance.find { |guidance| guidance.id == id }
  end

  class Tag
    include ActiveModel::Model
    attr_accessor :id, :label, :type, :document_type, :hint
  end

  class Guidance
    include ActiveModel::Model
    attr_accessor :id, :title, :body_govspeak
  end

  class PublishingMetadata
    include ActiveModel::Model
    attr_accessor :schema_name, :rendering_app
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type
  end
end
