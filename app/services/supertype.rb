# frozen_string_literal: true

class Supertype < ReadonlyModel
  attr_reader :id, :label, :description, :managed_elsewhere, :hint, :document_types

  def self.all
    @all ||= begin
      raw = YAML.load_file("app/formats/supertypes.yml")
      raw.map { |r| new.from_hash(r) }
    end
  end

  def self.find(id)
    item = all.find { |supertype| supertype.id == id }
    item || (raise RuntimeError, "Supertype #{id} not found")
  end

  def from_hash(hash)
    hash["document_types"] = hash["display_document_types"].to_a.map(&DocumentType.method(:find))
    assign_attributes(hash)
    self
  end

  def managed_elsewhere_url
    if managed_elsewhere["hostname"]
      Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
    else
      managed_elsewhere["path"]
    end
  end
end
