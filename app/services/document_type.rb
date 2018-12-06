# frozen_string_literal: true

class DocumentType
  attr_reader :contents, :id, :label, :managed_elsewhere, :publishing_metadata,
    :path_prefix, :tags, :guidance_govspeak, :description, :hint, :lead_image, :topics, :check_path_conflict

  def initialize(params = {})
    @id = params["id"]
    @label = params["label"]
    @managed_elsewhere = params["managed_elsewhere"]
    @contents = params["contents"].to_a.map(&Field.method(:new))
    @publishing_metadata = PublishingMetadata.new(params["publishing_metadata"])
    @path_prefix = params["path_prefix"]
    @tags = params["tags"].to_a.map(&TagField.method(:new))
    @guidance = params["guidance"].to_a.map(&Guidance.method(:new))
    @description = params["description"]
    @hint = params["hint"]
    @lead_image = params["lead_image"]
    @topics = params["topics"]
    @check_path_conflict = params["check_path_conflict"]
  end

  def self.find(id)
    item = all.find { |document_type| document_type.id == id }
    item || (raise RuntimeError, "Document type #{id} not found")
  end

  def self.all
    @all ||= begin
      types = YAML.load_file("app/formats/document_types.yml")
      types.map { |data| DocumentType.new(data) }
    end
  end

  def self.add(params)
    document_type = new(params)
    all << document_type
    document_type
  end

  def managed_elsewhere_url
    Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
  end

  def guidance_for(id)
    @guidance.find { |guidance| guidance.id == id }
  end

  class TagField
    include ActiveModel::Model
    attr_accessor :id, :label, :type, :document_type, :hint
  end

  class Guidance
    include ActiveModel::Model
    attr_accessor :id, :title, :body_govspeak
  end

  class PublishingMetadata
    include ActiveModel::Model
    attr_accessor :schema_name, :rendering_app
  end

  class Field
    include ActiveModel::Model
    attr_accessor :id, :label, :type
  end
end
