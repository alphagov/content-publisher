# frozen_string_literal: true

class Supertype
  attr_reader :id, :label, :description, :managed_elsewhere, :hint, :document_types

  def initialize(params = {})
    @id = params["id"]
    @label = params["label"]
    @description = params["description"]
    @managed_elsewhere = params["managed_elsewhere"]
    @hint = params["hint"]
    @document_types = params["display_document_types"].to_a.map { |type| DocumentType.find(type) }
  end

  def self.all
    @all ||= begin
      raw = YAML.load_file("app/formats/supertypes.yml")
      raw.map { |r| Supertype.new(r) }
    end
  end

  def self.find(id)
    item = all.find { |supertype| supertype.id == id }
    item || (raise RuntimeError, "Supertype #{id} not found")
  end

  def managed_elsewhere_url
    if managed_elsewhere["hostname"]
      Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
    else
      managed_elsewhere["path"]
    end
  end
end
