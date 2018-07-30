# frozen_string_literal: true

class DocumentTypeSchema
  attr_reader :fields, :document_type, :name, :supertype, :managed_elsewhere, :schema_name, :rendering_app

  def initialize(params = {})
    @document_type = params["document_type"]
    @name = params["name"]
    @supertype = params["supertype"]
    @managed_elsewhere = params["managed_elsewhere"]
    @fields = params["fields"].to_a.map { |field| Field.new(field) }
    @schema_name = params["schema_name"]
    @rendering_app = params["rendering_app"]
  end

  def self.find(document_type)
    item = all.find { |schema| schema.document_type == document_type }
    item || (raise RuntimeError, "Document type #{document_type} not found")
  end

  def self.all
    @all ||= begin
      types = YAML.load_file("app/formats/document_types.yml")
      types.map { |data| DocumentTypeSchema.new(data) }
    end
  end

  def managed_elsewhere?
    managed_elsewhere
  end

  def managed_elsewhere_url
    Plek.find(managed_elsewhere.fetch('hostname')) + managed_elsewhere.fetch('path')
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type, :validations
  end
end
