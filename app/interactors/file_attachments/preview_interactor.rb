# frozen_string_literal: true

class FileAttachments::PreviewInteractor
  include Interactor

  delegate :params,
           :edition,
           :attachment_revision,
           :asset,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_attachment
      check_uploaded
      check_available
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def find_attachment
    context.attachment_revision = edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def check_uploaded
    attachment_revision.ensure_assets
    context.asset = attachment_revision.asset("file")

    if asset.absent?
      PreviewAssetService.new(edition).upload_asset(asset)
      context.fail!(can_preview: false)
    end
  rescue GdsApi::BaseError
    context.fail!(api_error: true)
  end

  def check_available
    service = PreviewAssetService.new(edition)
    context.can_preview = service.can_preview_asset?(asset)
  rescue GdsApi::BaseError
    context.fail!(api_error: true)
  end
end
