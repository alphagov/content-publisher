# frozen_string_literal: true

class FileAttachments::PreviewInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :attachment_revision,
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
    assert_edition_state(edition, &:editable?)
  end

  def find_attachment
    context.attachment_revision = edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def find_or_upload_asset
    asset = attachment_revision.asset

    if asset.absent?
      PreviewAssetService.new(edition).put(asset)
      context.can_preview = false
      return
    end

    response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h
    context.can_preview = response["state"] == "uploaded"
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end
end
