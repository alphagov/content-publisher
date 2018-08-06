# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class PathGeneratorService
  class ErrorGeneratingPath < RuntimeError
  end

  def initialize(max_repeated_titles = 1000)
    @max_repeated_titles = max_repeated_titles
  end

  def path(document, proposed_title)
    prefix = document.document_type_schema.path_prefix
    slug = proposed_title.parameterize
    base_path = create_path(prefix, slug)
    return base_path unless document_exists_with_path?(base_path, document)
    find_a_unique_path(document, prefix, slug)
  end

private

  def find_a_unique_path(document, prefix, slug)
    (1..@max_repeated_titles).each do |appended_count|
      base_path = create_path(prefix, slug, appended_count)
      return base_path unless document_exists_with_path?(base_path, document)
    end
    raise(ErrorGeneratingPath, "Already >#{@max_repeated_titles} paths with same title.")
  end

  def document_exists_with_path?(base_path, document)
    doc = Document.where(base_path: base_path).first
    doc && doc != document
  end

  def create_path(prefix, slug, count = nil)
    if count
      "#{prefix}/#{slug}-#{count}"
    else
      "#{prefix}/#{slug}"
    end
  end
end
