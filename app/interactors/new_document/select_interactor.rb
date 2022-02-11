class NewDocument::SelectInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :document,
           :document_type_selection,
           :selected_option,
           to: :context

  def call
    find_selection
    check_for_issues
    return unless selected_option.document_type?

    create_document
    create_timeline_entry
  end

private

  def find_selection
    context.document_type_selection = DocumentTypeSelection.find(params[:type])
    context.selected_option = document_type_selection.find_option(params[:selected_option_id])
  end

  def check_for_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:document_type_selection, :not_selected) unless selected_option

    context.fail!(issues:) if issues.any?
  end

  def create_document
    context.document = CreateDocumentService.call(document_type_id: selected_option.id, user:)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :created,
                                           status: document.current_edition.status)
  end
end
