# frozen_string_literal: true

class Supertype
  include InitializeWithHash

  attr_reader :id, :label, :description, :managed_elsewhere, :hint, :document_types

  def self.all
    @all ||= begin
      hashes = YAML.load_file(Rails.root.join("app/formats/supertypes.yml"))

      hashes.map do |hash|
        hash["document_types"] = hash["display_document_types"].to_a.map(&DocumentType.method(:find))
        new(hash)
      end
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
