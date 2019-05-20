# frozen_string_literal: true

class FileAttachmentsController < ApplicationController
  include FileAttachmentHelper

  def index
    @edition = Edition.find_current(document: params[:document])
    render layout: rendering_context
  end

  def show
    @edition = Edition.find_current(document: params[:document])

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def preview
    result = FileAttachments::PreviewInteractor.call(params: params)
    attachment_revision, edition, can_preview, api_error = result.to_h.values_at(:attachment_revision,
                                                                                 :edition,
                                                                                 :can_preview,
                                                                                 :api_error)

    if api_error || !can_preview
      render :preview_pending
    else
      redirect_to file_attachment_preview_url(attachment_revision, edition.document)
    end
  end

  def create
    result = FileAttachments::CreateInteractor.call(params: params, user: current_user)
    edition = result.edition
    attachment_revision = result.attachment_revision
    issues = result.issues

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("file_attachments.index.flashes.upload_requirements"),
        "items" => issues.items,
      }

      render :index,
             assigns: { edition: edition,
                        issues: issues },
             status: :unprocessable_entity
    else
      redirect_to file_attachment_path(edition.document, attachment_revision.file_attachment)
    end
  end

  def destroy
    result = FileAttachments::DestroyInteractor.call(params: params, user: current_user)
    attachment_revision = result.attachment_revision

    redirect_to file_attachments_path(params[:document]),
                notice: t("file_attachments.index.flashes.deleted",
                          file: attachment_revision.filename)
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def update
    result = FileAttachments::UpdateInteractor.call(params: params,
                                                    user: current_user)
    edition = result.edition
    attachment_revision = result.file_attachment_revision
    issues = result.issues

    if issues
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("file_attachments.index.flashes.upload_requirements"),
        "items" => issues.items,
      }

      render :edit,
             title: params.dig(:file_attachment, :title),
             assigns: { edition: edition,
                        issues: issues,
                        attachment: attachment_revision },
             status: :unprocessable_entity
    else
      flash[:notice] = I18n.t!("file_attachments.edit.flashes.update_confirmation")
      redirect_to file_attachments_path(edition.document)
    end
  end
end
