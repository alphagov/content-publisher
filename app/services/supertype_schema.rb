# frozen_string_literal: true

class SupertypeSchema
  attr_reader :id, :label, :description

  def initialize(params = {})
    @id = params["id"]
    @label = params["label"]
    @description = params["description"]
  end

  def self.all
    @all ||= begin
      raw = YAML.load_file("app/formats/supertypes.yml")
      raw.map { |r| SupertypeSchema.new(r) }
    end
  end

  def self.find(schema_id)
    item = all.find { |schema| schema.id == schema_id }
    item || (raise RuntimeError, "Supertype #{schema_id} not found")
  end

  def document_types
    DocumentTypeSchema.all.select { |schema| schema.supertype == self }
  end
end
