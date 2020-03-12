class FileAttachmentsController < ApplicationController
  include FileAttachmentHelper

  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports inline attachments") do
      @edition.document_type.attachments.inline_file_only?
    end
  end

  def new
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports featured attachments") do
      @edition.document_type.attachments.featured?
    end
  end

  def show
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    assert_edition_feature(@edition, assertion: "supports inline attachments") do
      @edition.document_type.attachments.inline_file_only?
    end

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def confirm_delete
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def preview
    result = FileAttachments::PreviewInteractor.call(params: params, user: current_user)
    can_preview, api_error = result.to_h.values_at(:can_preview, :api_error)

    if api_error || !can_preview
      render :preview_pending, status: :service_unavailable
    else
      attachment_revision, edition = result.to_h.values_at(:attachment_revision,
                                                           :edition)
      redirect_to file_attachment_preview_url(attachment_revision, edition.document)
    end
  end

  def download
    edition = Edition.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)

    attachment_revision = edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])

    send_data(
      attachment_revision.blob.download,
      filename: attachment_revision.filename,
      type: attachment_revision.content_type,
    )
  end

  def create
    result = FileAttachments::CreateInteractor.call(params: params, user: current_user)
    edition, attachment_revision, issues = result.to_h.values_at(:edition,
                                                                 :attachment_revision,
                                                                 :issues)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(
          link_options: {
            file_attachment_upload: { href: how_to_use_publisher_path(anchor: "attachments"),
                                      target: :blank },
          },
        ),
      }

      render params[:wizard] == "new" ? :new : :index,
             assigns: { edition: edition,
                        issues: issues },
             status: :unprocessable_entity
    elsif params[:wizard] == "new"
      redirect_to featured_attachments_path(edition.document, attachment_revision.file_attachment)
    else
      redirect_to file_attachment_path(edition.document, attachment_revision.file_attachment)
    end
  end

  def destroy
    result = FileAttachments::DestroyInteractor.call(params: params, user: current_user)
    attachment_revision = result.attachment_revision

    if params[:wizard] == "featured"
      redirect_to featured_attachments_path(params[:document])
    else
      redirect_to file_attachments_path(params[:document]),
                  notice: t("file_attachments.index.flashes.deleted",
                            file: attachment_revision.filename)
    end
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def update
    result = FileAttachments::UpdateInteractor.call(params: params, user: current_user)
    edition, attachment_revision, issues, unchanged =
      result.to_h.values_at(:edition, :file_attachment_revision, :issues, :unchanged)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(
          link_options: {
            file_attachment_upload: { href: how_to_use_publisher_path(anchor: "attachments"),
                                      target: :blank },
          },
        ),
      }

      render :edit,
             title: params.dig(:file_attachment, :title),
             assigns: { edition: edition,
                        issues: issues,
                        attachment: attachment_revision },
             status: :unprocessable_entity
    elsif unchanged
      redirect_to file_attachments_path(edition.document)
    else
      flash[:notice] = I18n.t!("file_attachments.edit.flashes.update_confirmation")
      redirect_to file_attachments_path(edition.document)
    end
  end
end
