# frozen_string_literal: true

class SupertypeSchema
  attr_reader :id, :label, :description, :managed_elsewhere, :hint, :document_types

  def initialize(params = {})
    @id = params["id"]
    @label = params["label"]
    @description = params["description"]
    @managed_elsewhere = params["managed_elsewhere"]
    @hint = params["hint"]
    @document_types = params["display_document_types"].to_a.map { |type| DocumentTypeSchema.find(type) }
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

  def managed_elsewhere_url
    if managed_elsewhere["hostname"]
      Plek.find(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
    else
      managed_elsewhere["path"]
    end
  end
end
