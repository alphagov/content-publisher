# frozen_string_literal: true

# Used as a stand-in for a File / Rack::Multipart::UploadedFile object when
# passed to GdsApi::AssetManager#create_asset. The interface is required for
# uploading a file using the restclient we used in the backend.
#
# https://github.com/rest-client/rest-client/blob/master/lib/restclient/payload.rb#L181-L194
#
# This is done by delegating to 'io' which should implement the IO interface
# (e.g. StringIO) and adds methods to return filename, content_type and path.
class PreviewAssetService::UploadedFile < SimpleDelegator
  attr_reader :asset

  def initialize(asset)
    super(StringIO.new(asset.bytes))
    @asset = asset
  end

  def content_type
    asset.content_type
  end

  def path
    asset.filename
  end

  def filename
    File.basename(asset.filename)
  end
end
