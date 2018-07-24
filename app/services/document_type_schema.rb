# frozen_string_literal: true

class DocumentTypeSchema
  include ActiveModel::Model
  attr_accessor :document_type, :name, :supertype, :managed_elsewhere
  attr_writer :fields

  def self.find(document_type)
    all.find { |schema| schema.document_type == document_type }
  end

  def self.all
    @all ||= begin
      types = YAML.load_file("app/formats/document_types.yml")
      types.map { |data| DocumentTypeSchema.new(data) }
    end
  end

  def fields
    @fields.to_a.map { |field| Field.new(field) }
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type
  end
end
