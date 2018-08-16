# frozen_string_literal: true

class DocumentTypeSchema
  attr_reader :contents, :id, :label, :supertype, :managed_elsewhere, :publishing_metadata, :path_prefix, :associations, :guidance, :validations

  def initialize(params = {})
    @id = params["id"]
    @label = params["label"]
    @supertype = SupertypeSchema.find(params["supertype"])
    @managed_elsewhere = params["managed_elsewhere"]
    @contents = params["contents"].to_a.map(&Field.method(:new))
    @publishing_metadata = PublishingMetadata.new(params["publishing_metadata"])
    @path_prefix = params["path_prefix"]
    @associations = params["associations"].to_a.map(&Association.method(:new))
    @guidance = params["guidance"].to_a.map(&Guidance.method(:new))
    @validations = params["validations"].to_a.map(&ValidationSchema.method(:new))
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

  def self.create(params)
    schema = new(params)
    all << schema
    schema
  end

  def managed_elsewhere_url
    Plek.find(managed_elsewhere.fetch('hostname')) + managed_elsewhere.fetch('path')
  end

  def guidance_for(id)
    @guidance.find { |guidance| guidance.id == id }
  end

  class Association
    include ActiveModel::Model
    attr_accessor :id, :label, :type, :document_type
  end

  class Guidance
    include ActiveModel::Model
    attr_accessor :id, :title, :body
  end

  class PublishingMetadata
    include ActiveModel::Model
    attr_accessor :schema_name, :rendering_app
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type, :validations
  end

  class ValidationSchema
    include ActiveModel::Model
    attr_accessor :id, :type, :message, :settings
  end
end
