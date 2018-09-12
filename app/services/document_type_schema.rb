# frozen_string_literal: true

class DocumentTypeSchema
  attr_reader :contents, :id, :label, :managed_elsewhere, :publishing_metadata,
    :path_prefix, :tags, :guidance, :description, :hint, :lead_image, :edit_only

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
    @edit_only = params["edit_only"]
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
    Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
  end

  def guidance_for(id)
    @guidance.find { |guidance| guidance.id == id }
  end

  class Tag
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
end
