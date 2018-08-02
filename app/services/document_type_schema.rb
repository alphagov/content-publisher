# frozen_string_literal: true

class DocumentTypeSchema
  attr_reader :contents, :id, :name, :supertype, :managed_elsewhere, :publishing_metadata, :path_prefix, :associations

  def initialize(params = {})
    @id = params["id"]
    @name = params["name"]
    @supertype = SupertypeSchema.find(params["supertype"])
    @managed_elsewhere = params["managed_elsewhere"]
    @contents = params["contents"].to_a.map { |field| Field.new(field) }
    @publishing_metadata = PublishingMetadata.new(params["publishing_metadata"])
    @path_prefix = params["path_prefix"]
    @associations = params["associations"].to_a.map { |field| Field.new(field) }
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

  def managed_elsewhere_url
    Plek.find(managed_elsewhere.fetch('hostname')) + managed_elsewhere.fetch('path')
  end

  def associations?
    associations.any?
  end

  class PublishingMetadata
    include ActiveModel::Model
    attr_accessor :schema_name, :rendering_app
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type, :validations
  end
end
