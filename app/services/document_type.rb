# frozen_string_literal: true

class DocumentType < ReadonlyModel
  attr_reader :contents, :id, :label, :managed_elsewhere, :publishing_metadata,
    :path_prefix, :tags, :guidance_govspeak, :description, :hint, :lead_image, :topics, :check_path_conflict

  def self.find(id)
    item = all.find { |document_type| document_type.id == id }
    item || (raise RuntimeError, "Document type #{id} not found")
  end

  def self.all
    @all ||= begin
      types = YAML.load_file("app/formats/document_types.yml")
      types.map { |data| new.from_hash(data) }
    end
  end

  def self.add(params)
    document_type = new.from_hash(params)
    all << document_type
    document_type
  end

  def from_hash(hash)
    hash["contents"] = hash["contents"].to_a.map(&Field.method(:new))
    hash["publishing_metadata"] = PublishingMetadata.new(hash["publishing_metadata"])
    hash["tags"] = hash["tags"].to_a.map(&TagField.method(:new))
    hash["guidance"] = hash["guidance"].to_a.map(&Guidance.method(:new))
    assign_attributes(hash)
    self
  end

  def managed_elsewhere_url
    Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
  end

  def guidance_for(id)
    @guidance.find { |guidance| guidance.id == id }
  end

  class TagField < ReadonlyModel
    attr_reader :id, :label, :type, :document_type, :hint
  end

  class Guidance < ReadonlyModel
    attr_reader :id, :title, :body_govspeak
  end

  class PublishingMetadata < ReadonlyModel
    attr_reader :schema_name, :rendering_app
  end

  class Field < ReadonlyModel
    attr_reader :id, :label, :type
  end
end
