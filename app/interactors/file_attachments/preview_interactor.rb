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
      find_or_upload_asset
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

  def find_or_upload_asset
    context.asset = attachment_revision.asset

    if asset.absent?
      PreviewAssetService.new(edition).upload_asset(asset)
      context.can_preview = false
      return
    end

    service = PreviewAssetService.new(edition)
    context.can_preview = service.can_preview_asset?(asset)
  rescue GdsApi::BaseError
    context.fail!(api_error: true)
  end
end
