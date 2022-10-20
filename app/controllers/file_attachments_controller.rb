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
    result = FileAttachments::PreviewInteractor.call(params:, user: current_user)
    can_preview, api_error = result.to_h.values_at(:can_preview, :api_error)

    if api_error || !can_preview
      render :preview_pending, status: :service_unavailable
    else
      attachment_revision, edition = result.to_h.values_at(:attachment_revision,
                                                           :edition)
      redirect_to file_attachment_preview_url(attachment_revision, edition), allow_other_host: true
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
    result = FileAttachments::CreateInteractor.call(params:, user: current_user)
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

      render params[:wizard] == "featured-attachment-upload" ? :new : :index,
             assigns: { edition:,
                        issues: },
             status: :unprocessable_entity
    elsif params[:wizard] == "featured-attachment-upload"
      redirect_to edit_file_attachment_path(edition.document,
                                            attachment_revision.file_attachment,
                                            wizard: params[:wizard])
    else
      redirect_to file_attachment_path(edition.document, attachment_revision.file_attachment)
    end
  end

  def destroy
    result = FileAttachments::DestroyInteractor.call(params:, user: current_user)
    attachment_revision = result.attachment_revision

    if params[:wizard] == "featured-attachment-delete"
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

    assert_edition_feature(@edition, assertion: "supports featured attachments") do
      @edition.document_type.attachments.featured?
    end
  end

  def update
    result = FileAttachments::UpdateInteractor.call(params:, user: current_user)
    edition, attachment_revision, issues =
      result.to_h.values_at(:edition, :file_attachment_revision, :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :edit,
             assigns: { edition:,
                        attachment: attachment_revision,
                        issues: },
             status: :unprocessable_entity
    else
      redirect_to featured_attachments_path(edition.document)
    end
  end

  def replace
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)

    @attachment = @edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def update_file
    result = FileAttachments::UpdateFileInteractor.call(params:, user: current_user)
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

      render :replace,
             title: params.dig(:file_attachment, :title),
             assigns: { edition:,
                        issues:,
                        attachment: attachment_revision },
             status: :unprocessable_entity
    elsif params[:wizard] == "featured-attachment-replace"
      redirect_to featured_attachments_path(edition.document)
    elsif params[:wizard] == "featured-attachment-upload"
      redirect_to edit_file_attachment_path(edition.document,
                                            attachment_revision.file_attachment,
                                            wizard: params[:wizard])
    else
      flash[:notice] = t("file_attachments.replace.flashes.update_confirmation") unless unchanged
      redirect_to file_attachments_path(edition.document)
    end
  end
end
