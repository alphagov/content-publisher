# frozen_string_literal: true

class DocumentTypeSchema
  attr_reader :fields, :document_type, :name, :supertype, :managed_elsewhere

  def initialize(params = {})
    @document_type = params["document_type"]
    @name = params["name"]
    @supertype = params["supertype"]
    @managed_elsewhere = params["managed_elsewhere"]
    @fields = params["fields"].to_a.map { |field| Field.new(field) }
  end

  def self.find(document_type)
    all.find { |schema| schema.document_type == document_type }
  end

  def self.all
    @all ||= begin
      types = YAML.load_file("app/formats/document_types.yml")
      types.map { |data| DocumentTypeSchema.new(data) }
    end
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type
  end
end
