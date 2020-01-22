# frozen_string_literal: true

class DocumentType
  extend DocumentTypeHelper # for static methods
  include DocumentTypeHelper
  include InitializeWithHash

  attr_reader :contents, :id, :managed_elsewhere, :publishing_metadata, :label,
              :path_prefix, :tags, :images, :topics, :check_path_conflict

  def self.find(id)
    item = all.find { |document_type| document_type.id == id }
    item || (raise RuntimeError, "Document type #{id} not found")
  end

  def self.all
    @all ||= begin
      hashes = YAML.load_file(Rails.root.join("config/document_types.yml"))

      hashes.map do |hash|
        hash["contents"] = hash["contents"].to_a.map(&Field.method(:new))
        hash["tags"] = (hash["tags"] || []).map do |tag_config|
          tag_i18n_data = "document_types.#{hash['id']}.fields.#{tag_config['id']}"
          if t_doctype_exists?(tag_i18n_data)
            TagField.new(tag_config.merge(t_doctype(tag_i18n_data)))
          end
        end
        hash["tags"] = hash["tags"].compact
        hash["publishing_metadata"] = PublishingMetadata.new(hash["publishing_metadata"].to_h)
        hash["topics"] = true # this feature is only disabled in tests
        new(hash)
      end
    end
  end

  def managed_elsewhere_url
    Plek.new.external_url_for(managed_elsewhere.fetch("hostname")) + managed_elsewhere.fetch("path")
  end

  class TagField
    include InitializeWithHash
    attr_reader :id, :label, :type, :document_type, :hint
  end

  class PublishingMetadata
    include InitializeWithHash
    attr_reader :schema_name, :rendering_app
  end

  class Field
    include InitializeWithHash
    attr_reader :id, :label, :type
  end
end
