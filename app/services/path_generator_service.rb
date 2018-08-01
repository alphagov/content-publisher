# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class PathGeneratorService
  def path(document, proposed_title)
    base_path = document.document_type_schema.path_prefix + '/' + proposed_title.parameterize
    return false if path_in_publishing_api?(base_path)
    base_path
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
