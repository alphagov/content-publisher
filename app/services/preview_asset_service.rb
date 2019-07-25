# frozen_string_literal: true

class PreviewAssetService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def upload_assets
    edition.image_revisions.each(&:ensure_assets)
    edition.assets.each { |asset| upload_asset(asset) }
  end

  def upload_asset(asset)
    if asset.draft?
      update(asset)
    elsif asset.absent?
      upload(asset)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def payload
    auth_bypass_id = PreviewAuthBypassService.new(edition).auth_bypass_id
    { draft: true, auth_bypass_ids: [auth_bypass_id] }
  end

  def update(asset)
    GdsApi.asset_manager.update_asset(asset.asset_manager_id, payload)
  end

  def upload(asset)
    upload = GdsApi.asset_manager.create_asset(
      payload.merge(file: UploadedFile.new(asset)),
    )

    asset.update!(file_url: upload["file_url"], state: :draft)
  end

  # Used as a stand-in for a File / Rack::Multipart::UploadedFile object when
  # passed to GdsApi::AssetManager#create_asset. The interface is required for
  # uploading a file using the restclient we used in the backend.
  #
  # https://github.com/rest-client/rest-client/blob/master/lib/restclient/payload.rb#L181-L194
  #
  # This is done by delegating to 'io' which should implement the IO interface
  # (e.g. StringIO) and adds methods to return filename, content_type and path.
  class UploadedFile < SimpleDelegator
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
end
