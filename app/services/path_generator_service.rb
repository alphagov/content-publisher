# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class PathGeneratorService
  class ErrorGeneratingPath < RuntimeError
  end

  def path(document, proposed_title)
    base_path = document.document_type_schema.path_prefix + '/' + proposed_title.parameterize
    return base_path unless path_in_publishing_api?(base_path)
    (1..5).each do |appended_count|
      base_path = "#{document.document_type_schema.path_prefix}/#{proposed_title.parameterize}-#{appended_count}"
      return base_path unless path_in_publishing_api?(base_path)
    end
    raise(ErrorGeneratingPath, 'Already >5 paths with same title.')
  end

private

  def path_in_publishing_api?(base_path)
    publishing_api.lookup_content_id(base_path: base_path)
  end

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end
end
