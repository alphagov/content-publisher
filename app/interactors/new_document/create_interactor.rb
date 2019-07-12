# frozen_string_literal: true

class NewDocument::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :document_type,
           :supertype,
           :document,
           to: :context

  def call
    find_supertype
    check_for_issues
    find_document_type
    check_we_support_it
    create_document
    create_timeline_entry
  end

private

  def find_supertype
    context.supertype = Supertype.find(params[:supertype])
  end

  def check_for_issues
    return if params[:document_type].present?

    context.fail!(issues: document_type_issues)
  end

  def find_document_type
    context.document_type = DocumentType.find(params[:document_type])
  end

  def check_we_support_it
    context.fail!(managed_elsewhere: true) if document_type.managed_elsewhere
  end

  def create_document
    context.document = Document.create_initial(
      document_type_id: params[:document_type], tags: default_tags, user: user,
    )
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :created,
                                           status: document.current_edition.status)
  end

  def document_type_issues
    Requirements::CheckerIssues.new([
      Requirements::Issue.new(:document_type, :not_selected),
    ])
  end

  def default_tags
    user.organisation_content_id ? { primary_publishing_organisation: [user.organisation_content_id] } : {}
  end
end
